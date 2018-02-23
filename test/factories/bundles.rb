FactoryGirl.define do
  factory :bundle, class: Bundle do
    sequence(:name) { |i| "Bundle Name #{i}" }
    sequence(:version) { |i| "#{2017 + i}.0.0" }
    sequence(:title) { |i| "Bundle Name #{i}" }

    factory :static_bundle do
      active true
      done_importing true
      name 'Static Bundle'
      title 'Static Bundle'
      version '2017.0.2'
      extensions { %w[map_reduce_utils hqmf_utils] }
      records { [] }
      measure_period_start 1_451_606_400 # Jan 1 2016
      effective_date 1_483_228_799 # Dec 31 2016

      after(:create) do |bundle|
        # Load the extensions included in the bundle from the filesystem into mongo
        Dir.glob(Rails.root.join('test', 'fixtures', 'library_functions', '*.js')).each do |js_path|
          fn = "function () {\n #{File.read(js_path)} \n }"
          name = File.basename(js_path, '.js')
          Mongoid.default_client['system.js'].replace_one({ '_id' => name },
                                                          { '_id' => name,
                                                            'value' => BSON::Code.new(fn) }, upsert: true)
        end

        # Always include a complete measure (BE65090C-EB1F-11E7-8C3F-9A214CF093AE)
        measure = create(:static_measure, bundle_id: bundle._id)
        measure['id'] = measure.hqmf_id
        measure.save

        # Always include a random measure with a diagnosis
        diag_measure = create(:measure_with_diagnosis, bundle_id: bundle._id)
        diag_measure['id'] = diag_measure.hqmf_id
        diag_measure.save

        # Include a random measures
        7.times do
          random_measure = create(:measure_without_diagnosis, bundle_id: bundle._id)
          random_measure['id'] = random_measure.hqmf_id
          random_measure.save
        end
        FactoryGirl.reload

        # Include 40 valuesets
        40.times do
          create(:value_set, bundle: bundle)
        end
        create(:value_set_payer, bundle: bundle)

        # Include a record that will evaluate against the static measure
        9.times do
          create(:static_mpl_record, bundle_id: bundle._id)
        end
      end
    end
  end
end
