require 'hqmf-parser'

module Cypress
  class CqlBundleImporter
    SOURCE_ROOTS = { bundle: 'bundle.json',
                     measures: 'measures', measures_info: 'measures_info.json',
                     results: 'results',
                     valuesets: File.join('value_sets', 'value-set-codes.csv'),
                     patients: 'patients' }.freeze
    COLLECTION_NAMES = ['bundles', 'records', 'measures', 'individual_results', 'system.js'].freeze
    DEFAULTS = { type: nil,
                 update_measures: true,
                 clear_collections: COLLECTION_NAMES }.freeze

    # Import a quality bundle into the database. This includes metadata, measures, test patients, supporting JS libraries, and expected results.
    #
    # @param [File] zip The bundle zip file.
    # @param [String] Type of measures to import, either 'ep', 'eh' or nil for all
    # @param [Boolean] keep_existing If true, delete all current collections related to patients and measures.

    def self.import(zip, options = {})
      options = DEFAULTS.merge(options)
      @measure_id_hash = {}
      @patient_id_hash = {}

      bundle = nil
      Zip::ZipFile.open(zip.path) do |zip_file|
        bundle = unpack_bundle(zip_file)
        check_bundle_versions(bundle)

        # Store the bundle metadata.
        raise bundle.errors.full_messages.join(',') unless bundle.save

        puts 'bundle metadata unpacked...'
        unpack_and_store_valuesets(zip_file, bundle)
        unpack_and_store_measures(zip_file, options[:type], bundle)
        unpack_and_store_cqm_patients(zip_file, options[:type], bundle)
        unpack_and_store_results(zip_file, options[:type], bundle)
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
      old_year_err = 'Please use bundles for year 2018 or later.'
      raise old_year_err if bundle.version[0..3].to_i < 2018

      same_year_err = "A non-deprecated bundle with year #{bundle.version[0..3]} already exists in the database. Please deprecate previous bundles."
      raise same_year_err unless bundle_versions.select { |vers, _id| vers[0..3] == bundle.version[0..3] }.empty?
    end

    def self.unpack_bundle(zip)
      Bundle.new(JSON.parse(zip.read(SOURCE_ROOTS[:bundle]), max_nesting: 100).except('measures', 'patients'))
    end

    def self.unpack_and_store_valuesets(zip, bundle)
      previous_vs = nil
      current_row = nil
      codes = []
      csv_text = zip.read(SOURCE_ROOTS[:valuesets])
      csv = CSV.parse(csv_text, headers: true, col_sep: '|')
      csv.each do |row|
        current_row = row
        previous_vs = row['OID'] if previous_vs.nil?
        if row['OID'] != previous_vs
          CQM::ValueSet.new(oid: row['OID'], display_name: row['ValueSetName'], version: row['ExpansionVersion'],
                            concepts: codes, bundle: bundle).save
          previous_vs = row['OID']
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
      measure_info = JSON.load(File.open(File.join(zip.path,SOURCE_ROOTS[:measures_info])))
      measure_packages = Dir.glob(File.join(zip,SOURCE_ROOTS[:measures],'**', '*.zip'))
      measure_details = { 'episode_of_care'=> true }
      measure_packages.each_with_index do |measure_package_path, index|
        measure_package = File.new measure_package_path
        loader = Measures::CqlLoader.new(measure_package, measure_details)
        # will return an array of CQMMeasures, most of the time there will only be a single measure
        # if the measure is a composite measure, the array will contain the composite and all of the components
        measures = loader.extract_measures
        measures.each do |measure|
          cms_id = measure.cms_id[/(.*?)v/m, 1]
          measure.bundle_id = bundle.id
          measure.reporting_program_type = measure_info[cms_id].type || 'ep'
          measure.category = measure_info[cms_id].category  || 'Effective Clinical Care'
          measure.save!
        end
        report_progress('measures', (index * 100 / measure_packages.length)) if (index % 10).zero?
      end
      puts "\rLoading: Measures Complete          "
    end

    def self.unpack_and_store_cqm_patients(zip, type, bundle)
      entries = zip.glob(File.join(SOURCE_ROOTS[:patients], type || '**', 'json', '*.json'))
      entries.each_with_index do |entry, index|
        patient = CQM::BundlePatient.new(unpack_json(entry))

        patient['bundleId'] = bundle.id

        reconnect_references(patient)
        @patient_id_hash[patient.original_medical_record_number] = patient['id']
        patient.save
        report_progress('patients', (index * 100 / entries.length)) if (index % 10).zero?
      end
      puts "\rLoading: Patients Complete          "
    end

    # TODO: This will need to be updated for 2018.0.2 bundles that store relatedTo as an QDM::ID
    def self.reconnect_references(patient)
      patient.qdmPatient.dataElements.each do |data_element|
        next unless data_element['relatedTo']

        ref_array = []
        oid_hash = {}
        patient.qdmPatient.dataElements.each do |de|
          oid_hash[{ 'codes' => de['dataElementCodes'].map { |dec| dec['code'] }.flatten, 'start_time' => de['authorDatetime'].to_i }.hash] = de.id
        end
        data_element[:relatedTo].each do |ref|
          ref_array << oid_hash[{ 'codes' => ref['codes'], 'start_time' => ref['start_time'] }.hash]
        end
        data_element.relatedTo = ref_array
      end
    end

    def self.unpack_and_store_results(zip, _type, bundle)
      results = zip.glob(File.join(SOURCE_ROOTS[:results], '*.json')).map do |entry|
        contents = unpack_json(entry)
        contents.map! do |document|
          document['patient_id'] = @patient_id_hash[document['patient_id']]
          document['measure_id'] = @measure_id_hash[document['measure_id']]
          document['correlation_id'] = bundle.id.to_s
          document
        end
      end.flatten
      QDM::IndividualResult.collection.insert_many(results)
      compile_measure_relevance_hash
      puts "\rLoading: Results Complete          "
    end

    def self.compile_measure_relevance_hash
      @patient_id_hash.each_value do |patient|
        updated_patient = Patient.find(patient)
        updated_patient.calculation_results.each do |individual_result|
          updated_patient.update_measure_relevance_hash(individual_result)
        end
        updated_patient.save
      end
    end

    def self.unpack_json(entry)
      JSON.parse(entry.get_input_stream.read, max_nesting: false)
    end

    def self.report_progress(label, percent)
      print "\rLoading: #{label} #{percent}% complete"
      STDOUT.flush
    end

    def self.reconnect_valueset_references(measure)
      value_sets = []
      measure['cql_libraries'].each do |cql_library|
        cql_library['elm']['library']['valueSets'].each_pair do |_key, valuesets|
          valuesets.each do |valueset|
            value_sets << ValueSet.where(oid: valueset['id']).first
          end
        end
        next unless cql_library['elm']['library']['codes']

        cql_library['elm']['library']['codes'].each_pair do |_key, codes|
          codes.each do |code|
            code_system_name, code_system_version = code_system_name_and_version(cql_library, code['codeSystem']['name'])
            code_hash = ApplicationController.helpers.direct_reference_code_hash(code_system_name, code_system_version, code)
            value_sets << ValueSet.where(oid: code_hash).first
          end
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
