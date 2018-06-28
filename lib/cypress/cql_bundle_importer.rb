module Cypress
  class CqlBundleImporter
    SOURCE_ROOTS = { bundle: 'bundle.json',
                     measures: 'measures', results: 'results',
                     valuesets: File.join('value_sets', 'json', '*.json'),
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
    # rubocop:disable Metrics/MethodLength
    def self.import(zip, options = {})
      options = DEFAULTS.merge(options)
      @measure_id_hash = {}
      @patient_id_hash = {}

      bundle = nil
      Zip::ZipFile.open(zip.path) do |zip_file|
        bundle = unpack_bundle(zip_file)

        bundle_versions = Hash[* HealthDataStandards::CQM::Bundle.where({}).collect { |b| [b._id, b.version] }.flatten]
        raise "A bundle with version #{bundle.version} already exists in the database. " if bundle_versions.invert[bundle.version]

        # Store the bundle metadata.
        raise bundle.errors.full_messages.join(',') unless bundle.save
        puts 'bundle metadata unpacked...'

        unpack_and_store_valuesets(zip_file, bundle)
        unpack_and_store_measures(zip_file, options[:type], bundle)
        unpack_and_store_qdm_patients(zip_file, options[:type], bundle)
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
    # rubocop:enable Metrics/MethodLength

    def self.unpack_bundle(zip)
      HealthDataStandards::CQM::Bundle.new(JSON.parse(zip.read(SOURCE_ROOTS[:bundle]), max_nesting: 100))
    end

    def self.unpack_and_store_valuesets(zip, bundle)
      entries = zip.glob(SOURCE_ROOTS[:valuesets])
      entries.each_with_index do |entry, index|
        vs = HealthDataStandards::SVS::ValueSet.new(unpack_json(entry))
        vs['bundle_id'] = bundle.id
        HealthDataStandards::SVS::ValueSet.collection.insert_one(vs.as_document)
        report_progress('Value Sets', (index * 100 / entries.length)) if (index % 10).zero?
      end
      puts "\rLoading: Value Sets Complete          "
    end

    def self.unpack_and_store_measures(zip, type, bundle)
      entries = zip.glob(File.join(SOURCE_ROOTS[:measures], type || '**', '*.json'))
      entries.each_with_index do |entry, index|
        source_measure = unpack_json(entry)
        # we clone so that we have a source without a bundle id
        measure = source_measure.clone
        measure['bundle_id'] = bundle.id
        value_sets = []
        measure.value_set_oid_version_objects.each do |vsv|
          value_sets << HealthDataStandards::SVS::ValueSet.where(oid: vsv.oid, version: vsv.version).first.id
        end
        measure['value_sets'] = value_sets
        mes = Mongoid.default_client['measures'].insert_one(measure)
        @measure_id_hash[measure['bonnie_measure_id']] = mes.inserted_id
        report_progress('measures', (index * 100 / entries.length)) if (index % 10).zero?
      end
      puts "\rLoading: Measures Complete          "
    end

    def self.unpack_and_store_qdm_patients(zip, type, bundle)
      entries = zip.glob(File.join(SOURCE_ROOTS[:patients], type || '**', 'json', '*.json'))
      entries.each_with_index do |entry, index|
        patient = QDM::Patient.new(unpack_json(entry))
        patient['bundleId'] = bundle.id

        reconnect_references(patient)

        @patient_id_hash[patient['extendedData.master_patient_id']] = patient['id']
        patient.save
        report_progress('patients', (index * 100 / entries.length)) if (index % 10).zero?
      end
      puts "\rLoading: Patients Complete          "
    end

    def self.reconnect_references(patient)
      patient.dataElements.each do |data_element|
        next unless data_element['relatedTo']
        ref_array = []
        oid_hash = {}
        patient.dataElements.each do |de|
          oid_hash[{ 'codes' => de['dataElementCodes'].map { |dec| dec['code'] }.flatten, 'start_time' => de['authorDatetime'].to_i }.hash] = de.id
        end
        data_element['relatedTo'].each do |ref|
          ref_array << oid_hash[ref.hash]
        end
        data_element['relatedTo'] = ref_array
      end
    end

    def self.unpack_and_store_results(zip, _type, bundle)
      zip.glob(File.join(SOURCE_ROOTS[:results], '*.json')).each do |entry|
        contents = unpack_json(entry)
        contents.each do |document|
          # Replace ids in bundle, with ids created during import
          document['patient_id'] = @patient_id_hash[document['patient_id']]
          document['measure_id'] = @measure_id_hash[document['measure_id']]
          document['extendedData'] = {}
          document['extendedData']['correlation_id'] = bundle.id.to_s
          Mongoid.default_client['qdm_individual_results'].insert_one(document)
        end
      end
      puts "\rLoading: Results Complete          "
    end

    def self.unpack_json(entry)
      JSON.parse(entry.get_input_stream.read, max_nesting: false)
    end

    def self.report_progress(label, percent)
      print "\rLoading: #{label} #{percent}% complete"
      STDOUT.flush
    end
  end
end
