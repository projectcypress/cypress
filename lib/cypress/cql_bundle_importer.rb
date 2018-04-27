module Cypress
  class CqlBundleImporter

    SOURCE_ROOTS = { bundle: 'bundle.json',
                     measures: 'measures', results: 'results',
                     valuesets: File.join('value_sets','json','*.json'),
                     patients: 'patients'}
    COLLECTION_NAMES = ["bundles", "records", "measures", "individual_results", "system.js"]
    DEFAULTS = { type: nil,
                 update_measures: true,
                 clear_collections: COLLECTION_NAMES
                }

    # Import a quality bundle into the database. This includes metadata, measures, test patients, supporting JS libraries, and expected results.
    #
    # @param [File] zip The bundle zip file.
    # @param [String] Type of measures to import, either 'ep', 'eh' or nil for all
    # @param [Boolean] keep_existing If true, delete all current collections related to patients and measures.
    def self.import(zip,  options={})
      options = DEFAULTS.merge(options)
      @measure_id_hash = {}
      @patient_id_hash = {}

      bundle = nil
      Zip::ZipFile.open(zip.path) do |zip_file|

        bundle = unpack_bundle(zip_file)

        bundle_versions = Hash[* HealthDataStandards::CQM::Bundle.where({}).collect{|b| [b._id, b.version]}.flatten]
        if bundle_versions.invert[bundle.version]
          raise "A bundle with version #{bundle.version} already exists in the database. "
        end

        # Store the bundle metadata.
        unless bundle.save
          raise bundle.errors.full_messages.join(",")
        end
        puts "bundle metadata unpacked..."

        unpack_and_store_valuesets(zip_file, bundle)
        unpack_and_store_measures(zip_file, options[:type], bundle)
        unpack_and_store_qdm_patients(zip_file, options[:type], bundle)
        unpack_and_store_results(zip_file, options[:type], bundle)

      end

      return bundle
    ensure
      # If the bundle is nil or the bundle has never been saved then do not set done_importing or run save.
      if bundle && bundle.created_at
        bundle.done_importing = true
        bundle.save
      end
    end

    def self.unpack_bundle(zip)
      HealthDataStandards::CQM::Bundle.new(JSON.parse(zip.read(SOURCE_ROOTS[:bundle]),max_nesting: 100))
    end

    def self.unpack_and_store_valuesets(zip, bundle)
      entries = zip.glob(SOURCE_ROOTS[:valuesets])
      entries.each_with_index do |entry, index|
        vs = HealthDataStandards::SVS::ValueSet.new(unpack_json(entry))
        vs['bundle_id'] = bundle.id
        HealthDataStandards::SVS::ValueSet.collection.insert_one(vs.as_document)
        report_progress('Value Sets', (index*100/entries.length)) if index%10 == 0
      end
      puts "\rLoading: Value Sets Complete          "
    end

    def self.unpack_and_store_measures(zip, type, bundle)
      entries = zip.glob(File.join(SOURCE_ROOTS[:measures],type || '**','*.json'))
      entries.each_with_index do |entry, index|
        source_measure = unpack_json(entry)
        # we clone so that we have a source without a bundle id
        measure = source_measure.clone
        measure['bundle_id'] = bundle.id
        value_sets = []
        measure.value_set_oid_version_objects.each do |vsv|
          value_sets << HealthDataStandards::SVS::ValueSet.where(:oid => vsv.oid, :version => vsv.version).first.id
        end
        measure['value_sets'] = value_sets
        mes = Mongoid.default_client["measures"].insert_one(measure)
        @measure_id_hash[measure['bonnie_measure_id']] = mes.inserted_id
        report_progress('measures', (index*100/entries.length)) if index%10 == 0
      end
      puts "\rLoading: Measures Complete          "
    end

    def self.unpack_and_store_qdm_patients(zip, type, bundle)
      entries = zip.glob(File.join(SOURCE_ROOTS[:patients],type || '**','json','*.json'))
      entries.each_with_index do |entry, index|
        patient = QDM::Patient.new(unpack_json(entry))
        patient['bundleId'] = bundle.id
        @patient_id_hash[patient['extendedData.master_patient_id']] = patient['id']

        # TODO: loop through source data criteria, if there are references adds ids to hash
        # patient['source_data_criteria'].each do |data_criteria|
        #   source_data_id_hash[data_criteria['criteria_id']] = index
        #   if data_criteria['references'] != nil
        #     source_data_with_references.push(index)
        #     reference_ids = Array.new
        #     data_criteria['references'].each do |reference|
        #       reference_ids.push(reference['reference_id'])
        #     end
        #     source_data_reference_id_hash[data_criteria['criteria_id']] = reference_ids
        #   end
        #   index = index + 1
        # end
        # #if there are references, id references are reestablished
        # if source_data_with_references.size > 0
        #   reconnect_references(patient, source_data_with_references, source_data_reference_id_hash, source_data_id_hash)
        # end
        patient.save
        report_progress('patients', (index*100/entries.length)) if index%10 == 0
      end
      puts "\rLoading: Patients Complete          "
    end

    def self.unpack_and_store_results(zip, type, bundle)
      zip.glob(File.join(SOURCE_ROOTS[:results],'*.json')).each do |entry|
        contents = unpack_json(entry)
        contents.each do |document|

          # Replace ids in bundle, with ids created during import
          document['patient'] = @patient_id_hash[document['patient']]
          document['measure'] = @measure_id_hash[document['measure']]
          document['extended_data'] = {} 
          document['extended_data']['correlation_id'] = bundle.id
          Mongoid.default_client["individual_results"].insert_one(document)
        end
      end
      puts "\rLoading: Results Complete          "
    end

    def self.unpack_json(entry)
      JSON.parse(entry.get_input_stream.read,:max_nesting => 100)
    end

    def self.report_progress(label, percent)
      print "\rLoading: #{label} #{percent}% complete"
      STDOUT.flush
    end
  end
end
