FactoryBot.define do
  factory :filter_test, class: FilteringTest do
    sequence(:name) { |i| "Product Test Name #{i}" }

    factory :static_filter_test do
      name { 'Static Result' }
      _type { 'FilteringTest' }
      options { { 'filters' => { 'genders' => ['F'] } } }

      measure_ids { ['40280382-5FA6-FE85-0160-0918E74D2075'] }
      association :product, factory: :product_static_bundle
      after(:create) do |pt|
        patient = create(:static_test_patient, 'bundleId' => pt.bundle._id)
        patient.correlation_id = pt.id
        patient.medical_record_number = '1989db70-4d42-0135-8680-30999b0ed66f'
        patient.save
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1',
               'IPP' => 1,
               'DENOM' => 1,
               'DENEX' => 0,
               'NUMER' => 0)
        ar = ProductTestAggregateResult.create(product_test: pt, measure_id: pt.measures.first.id)
        CQM::IndividualResult.where(correlation_id: pt.id).each do |ir|
          ar.add_individual_result(ir)
        end
        ar.save
      end
    end
  end
end
