FactoryBot.define do
  factory :bundle, class: Bundle do
    sequence(:name) { |i| "Bundle Name #{i}" }
    sequence(:version) { |i| "#{2050 + i}.0.0" }
    sequence(:title) { |i| "Bundle Name #{i}" }

    # static_bundle includes random measures that will not execute in the cqm-execution-service
    # use executable_bundle for calculation tests
    factory :static_bundle do
      active { true }
      done_importing { true }
      name { 'Static Bundle' }
      title { 'Static Bundle' }
      version { '2019.0.0' }
      extensions { %w[map_reduce_utils hqmf_utils] }
      measure_period_start { 1_483_228_800 } # Jan 1 2017
      effective_date { 1_514_764_799 } # Dec 31 2017

      after(:build) do |bundle|
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
        create(:direct_reference_code_birth_date, bundle: bundle)
        create(:direct_reference_code_dead, bundle: bundle)
        create(:direct_reference_code_discharge_hospice, bundle: bundle)
        create(:direct_reference_code_discharge_home_hospice, bundle: bundle)

        # Always include a complete measure (BE65090C-EB1F-11E7-8C3F-9A214CF093AE)
        create(:static_measure, bundle_id: bundle._id)
        # Always include a complete proportion measure (40280382-5FA6-FE85-0160-0918E74D2075)
        create(:static_proportion_measure, bundle_id: bundle._id)

        # Always include 2 random measures with a diagnosis
        2.times do |count|
          diag_measure = create(:measure_with_diagnosis, bundle_id: bundle._id, seq_id: count)
          diag_measure['id'] = diag_measure.hqmf_id
          diag_measure.save
        end

        # Include 6 random measures
        6.times do |count|
          random_measure = create(:measure_without_diagnosis, bundle_id: bundle._id, seq_id: count + 2)
          random_measure['id'] = random_measure.hqmf_id
          random_measure.save
        end

        # Include a patient that will evaluate against the static measure
        9.times do |count|
          create(:static_bundle_patient, seq_id: count, bundleId: bundle._id)
        end
      end
    end

    # executable_bundle includes measures that execute in the cqm-execution-service
    factory :executable_bundle do
      active { true }
      done_importing { true }
      name { 'Executable Bundle' }
      title { 'Executable Bundle' }
      version { '2018.0.0.2' }
      extensions { %w[map_reduce_utils hqmf_utils] }
      measure_period_start { 1_483_228_800 } # Jan 1 2017
      effective_date { 1_514_764_799 } # Dec 31 2017

      after(:build) do |bundle|
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
        create(:static_measure, bundle_id: bundle._id)

        # Include a patient that will evaluate against the static measure
        9.times do |count|
          create(:patient, seq_id: count, bundleId: bundle._id)
        end
      end
    end
  end
end
