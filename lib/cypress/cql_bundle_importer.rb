require 'hqmf-parser'

module Cypress
  class CqlBundleImporter
    SOURCE_ROOTS = { bundle: 'bundle.json',
                     measures: 'measures', measures_info: 'measures-info.json',
                     results: 'results',
                     valuesets: File.join('value-sets', 'value-set-codes.csv'),
                     patients: 'patients' }.freeze
    COLLECTION_NAMES = ['bundles', 'records', 'measures', 'individual_results', 'system.js'].freeze
    DEFAULTS = { type: nil,
                 update_measures: true,
                 clear_collections: COLLECTION_NAMES }.freeze

    # Import a quality bundle into the database. This includes metadata, measures, test patients, supporting JS libraries, and expected results.
    #
    # @param [File] zip The bundle zip file.

    def self.import(zip)
      bundle = nil
      Zip::ZipFile.open(zip.path) do |zip_file|
        bundle = unpack_bundle(zip_file)
        check_bundle_versions(bundle)

        # Store the bundle metadata.
        raise bundle.errors.full_messages.join(',') unless bundle.save

        puts 'bundle metadata unpacked...'
        unpack_and_store_valuesets(zip_file, bundle)
        unpack_and_store_measures(zip_file, bundle)
        unpack_and_store_cqm_patients(zip_file, bundle)
        calculate_results(bundle)
      end

      bundle
    ensure
      # If the bundle is nil or the bundle has never been saved then do not set done_importing or run save.
      if bundle&.created_at
        bundle.done_importing = true
        bundle.save
      end
    end

    def self.check_bundle_versions(bundle)
      bundle_versions = Hash[* Bundle.where(deprecated: false).collect { |b| [b.version, b.id] }.flatten]

      # no bundles before 2018 and no non-deprecated bundles with same year
      old_year_err = 'Please use bundles for year 2019 or later.'
      raise old_year_err if bundle.version[0..3].to_i < 2019

      same_year_err = "A non-deprecated bundle with year #{bundle.version[0..3]} already exists in the database. Please deprecate previous bundles."
      raise same_year_err unless bundle_versions.select { |vers, _id| vers[0..3] == bundle.version[0..3] }.empty?
    end

    def self.unpack_bundle(zip)
      Bundle.new(JSON.parse(zip.read(SOURCE_ROOTS[:bundle]), max_nesting: 100).except('measures', 'patients'))
    end

    def self.unpack_and_store_valuesets(zip, bundle)
      current_row = nil
      previous_row = nil
      codes = []
      csv_text = zip.read(SOURCE_ROOTS[:valuesets])
      csv = CSV.parse(csv_text, headers: true, col_sep: '|')
      csv.each do |row|
        current_row = row
        previous_row = row if previous_row.nil?
        if row['OID'] != previous_row['OID']
          CQM::ValueSet.new(oid: previous_row['OID'], display_name: previous_row['ValueSetName'], version: previous_row['ExpansionVersion'],
                            concepts: codes, bundle: bundle).save
          previous_row = row
          codes = []
        end
        codes << CQM::Concept.new(code: row['Code'], code_system_oid: row['CodeSystemOID'], code_system_name: row['CodeSystemName'],
                                  code_system_version: row['CodeSystemVersion'], display_name: row['Descriptor'])
      end
      CQM::ValueSet.new(oid: current_row['OID'], display_name: current_row['ValueSetName'], version: current_row['ExpansionVersion'],
                        concepts: codes, bundle: bundle).save
      puts "\rLoading: Value Sets Complete          "
    end

    def self.unpack_and_store_measures(zip, bundle)
      measure_info = JSON.parse(zip.read(SOURCE_ROOTS[:measures_info]))
      measure_packages = zip.glob(File.join(SOURCE_ROOTS[:measures], '**', '*.zip'))
      measure_packages.each_with_index do |measure_package_zipped, index|
        temp_file_path = File.join('.', 'tmp.zip')
        FileUtils.rm_f(temp_file_path)
        measure_package_zipped.extract(temp_file_path)
        measure_package = File.new temp_file_path
        cms_id = measure_package_zipped.name[%r{measures\/(.*?)v}m, 1]
        measure_details = { 'episode_of_care' => measure_info[cms_id].episode_of_care }
        loader = Measures::CqlLoader.new(measure_package, measure_details)
        # will return an array of CQMMeasures, most of the time there will only be a single measure
        # if the measure is a composite measure, the array will contain the composite and all of the components
        measures = loader.extract_measures
        measures.each do |measure|
          save_extracted_measure(measure, measure_info, bundle)
        end
        FileUtils.rm_f(temp_file_path)
        report_progress('measures', (index * 100 / measure_packages.length)) if (index % 10).zero?
      end
      puts "\rLoading: Measures Complete          "
    end

    def self.save_extracted_measure(measure, measure_info, bundle)
      cms_id = measure.cms_id[/(.*?)v/m, 1]
      measure.bundle_id = bundle.id
      measure.reporting_program_type = measure_info[cms_id].type || 'ep'
      measure.category = measure_info[cms_id].category || 'Effective Clinical Care'
      # Remove prior valueset references
      measure.value_sets = []
      reconnect_valueset_references(measure, bundle)
      measure.save!
      dcab = Cypress::DataCriteriaAttributeBuilder.new
      dcab.build_data_criteria_for_measure(measure)
    end

    def self.unpack_and_store_cqm_patients(zip, bundle)
      qrda_files = zip.glob(File.join(SOURCE_ROOTS[:patients], '**', '*.xml'))
      qrda_files.each_with_index do |qrda_file, index|
        qrda = qrda_file.get_input_stream.read
        doc = Nokogiri::XML::Document.parse(qrda)
        doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
        patient = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
        patient['bundleId'] = bundle.id
        patient.update(_type: CQM::BundlePatient, correlation_id: bundle.id)
        patient.save!
        report_progress('patients', (index * 100 / qrda_files.length)) if (index % 10).zero?
      end
      puts "\rLoading: Patients Complete          "
    end

    def self.calculate_results(bundle)
      patient_ids = bundle.patients.map { |p| p.id.to_s }
      effective_date_end = Time.at(bundle.effective_date).in_time_zone.to_formatted_s(:number)
      effective_date = Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
      options = { 'effectiveDateEnd': effective_date_end, 'effectiveDate': effective_date }
      bundle.measures.each do |measure|
        SingleMeasureCalculationJob.perform_now(patient_ids, measure.id.to_s, bundle.id.to_s, options)
      end
      puts "\rLoading: Results Complete          "
    end

    def self.report_progress(label, percent)
      print "\rLoading: #{label} #{percent}% complete"
      STDOUT.flush
    end

    def self.reconnect_valueset_references(measure, bundle)
      value_sets = []
      measure.cql_libraries.each do |cql_library|
        value_sets.concat compile_value_sets_from_library(cql_library, bundle) if cql_library.elm.library['valueSets']
        next unless cql_library['elm']['library']['codes']

        value_sets.concat compile_drcs_from_library(cql_library, bundle)
      end
      value_sets.compact
      measure.value_sets.push(*value_sets)
    end

    def self.compile_value_sets_from_library(cql_library, bundle)
      value_sets = []
      cql_library.elm.library.valueSets.each_pair do |_key, valuesets|
        valuesets.each do |valueset|
          value_sets << ValueSet.where(oid: valueset['id'], bundle_id: bundle.id).first
        end
      end
      value_sets
    end

    def self.compile_drcs_from_library(cql_library, bundle)
      vs_model_cache = {}
      value_sets_from_single_code_references = Measures::ValueSetHelpers.make_fake_valuesets_from_single_code_references([cql_library['elm']],
                                                                                                                         vs_model_cache)
      find_or_save_drc_valuesets(value_sets_from_single_code_references, bundle)
    end

    def self.find_or_save_drc_valuesets(drc_valuesets, bundle)
      value_sets = []
      drc_valuesets.each do |drc_valueset|
        if ValueSet.where(oid: drc_valueset['oid'], bundle_id: bundle.id).empty?
          drc_valueset.bundle = bundle
          drc_valueset.save
          value_sets << drc_valueset
        else
          value_sets << ValueSet.where(oid: drc_valueset['oid'], bundle_id: bundle.id).first
        end
      end
      value_sets
    end

    def self.code_system_name_and_version(cql_library, code_system_name)
      code_system_def = cql_library['elm']['library']['codeSystems']['def'].find { |code_sys| code_sys['name'] == code_system_name }
      [code_system_def['id'], code_system_def['version']]
    end
  end
end
