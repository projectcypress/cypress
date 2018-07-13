FactoryBot.define do
  factory :bundle, class: Bundle do
    sequence(:name) { |i| "Bundle Name #{i}" }
    sequence(:version) { |i| "#{2017 + i}.0.0" }
    sequence(:title) { |i| "Bundle Name #{i}" }

    factory :static_bundle do
      entry = Rails.root.join('test', 'fixtures', 'artifacts', 'cms127v7.json')
      source_measure = JSON.parse(File.read(entry), max_nesting: 100)
      active true
      done_importing true
      name 'Static Bundle'
      title 'Static Bundle'
      version '2018.0.0.2'
      extensions { %w[map_reduce_utils hqmf_utils] }
      measure_period_start 1_325_376_000 # Jan 1 2012
      effective_date 1_356_998_399 # Dec 31 2012

      after(:create) do |bundle|
        # Load the extensions included in the bundle from the filesystem into mongo
        Dir.glob(Rails.root.join('test', 'fixtures', 'library_functions', '*.js')).each do |js_path|
          fn = "function () {\n #{File.read(js_path)} \n }"
          name = File.basename(js_path, '.js')
          Mongoid.default_client['system.js'].replace_one({ '_id' => name },
                                                          { '_id' => name,
                                                            'value' => BSON::Code.new(fn) }, upsert: true)
        end

        # Include 40 valuesets
        40.times do |count|
          create(:value_set, seq_id: count, bundle: bundle)
        end
        create(:value_set_payer, bundle: bundle)

        # Always include a complete measure (BE65090C-EB1F-11E7-8C3F-9A214CF093AE)
        measure = create(:static_measure, bundle_id: bundle._id)
        measure['value_set_oid_version_objects'] = source_measure['value_set_oid_version_objects']
        measure['elm_annotations'] = source_measure['elm_annotations']
        measure['observations'] = source_measure['observations']
        measure['elm'] = source_measure['elm']
        measure['main_cql_library'] = source_measure['main_cql_library']
        measure['cql_statement_dependencies'] = source_measure['cql_statement_dependencies']
        measure['populations_cql_map'] = source_measure['populations_cql_map']
        measure['id'] = measure.hqmf_id

        # TODO: find object ids for all of the oids in the measure
        valueset_id_list = []
        measure['value_set_oid_version_objects'].each do |vsv|
          # valueset_id_list << HealthDataStandards::SVS::ValueSet.where(:oid => vsv.oid, :version => vsv.version).first.id
        end
        measure['value_sets'] = valueset_id_list
        measure.save

        # Always include a random measure with a diagnosis
        diag_measure = create(:measure_with_diagnosis, bundle_id: bundle._id)
        diag_measure['value_set_oid_version_objects'] = source_measure['value_set_oid_version_objects']
        diag_measure['id'] = diag_measure.hqmf_id
        diag_measure.save

        # Include 7 random measures
        7.times do
          random_measure = create(:measure_without_diagnosis, bundle_id: bundle._id)
          random_measure['value_set_oid_version_objects'] = source_measure['value_set_oid_version_objects']
          random_measure['id'] = random_measure.hqmf_id
          random_measure.save
        end

        # Include a patient that will evaluate against the static measure
        9.times do
          create(:patient, bundleId: bundle._id)
        end
      end
    end
  end
end
