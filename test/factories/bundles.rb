FactoryBot.define do
  factory :bundle, class: Bundle do
    sequence(:name) { |i| "Bundle Name #{i}" }
    sequence(:version) { |i| "#{2017 + i}.0.0" }
    sequence(:title) { |i| "Bundle Name #{i}" }

    factory :static_bundle do
      entry = Rails.root.join('test', 'fixtures', 'artifacts', 'cms127v7.json')
      source_measure = JSON.parse(File.read(entry), max_nesting: 100)
      active { true }
      done_importing { true }
      name { 'Static Bundle' }
      title { 'Static Bundle' }
      version { '2018.0.0.2' }
      extensions { %w[map_reduce_utils hqmf_utils] }
      measure_period_start { 1_483_228_800 } # Jan 1 2017
      effective_date { 1_514_764_799 } # Dec 31 2017

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
        # measure['id'] = measure.hqmf_id

        # TODO: find object ids for all of the oids in the measure
        valueset_id_list = []
        measure['value_set_oid_version_objects'].each do |vsv|
          valueset_id_list << ValueSet.where(oid: vsv.oid, version: vsv.version).first.id
        end
        measure['value_sets'] = valueset_id_list
        measure.save

        # Always include 2 random measures with a diagnosis
        2.times do |count|
          diag_measure = create(:measure_with_diagnosis, bundle_id: bundle._id, seq_id: count)
          diag_measure['value_set_oid_version_objects'] = source_measure['value_set_oid_version_objects']
          diag_measure['id'] = diag_measure.hqmf_id
          diag_measure.save
        end

        # Include 6 random measures
        6.times do |count|
          random_measure = create(:measure_without_diagnosis, bundle_id: bundle._id, seq_id: count + 2)
          random_measure['value_set_oid_version_objects'] = source_measure['value_set_oid_version_objects']
          random_measure['id'] = random_measure.hqmf_id
          random_measure.save
        end

        # Include a patient that will evaluate against the static measure
        9.times do |count|
          create(:patient, seq_id: count, bundleId: bundle._id)
        end
      end
    end
  end
end
