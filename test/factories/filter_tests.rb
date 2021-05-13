# frozen_string_literal: true

FactoryBot.define do
  factory :filter_test, class: FilteringTest do
    sequence(:name) { |i| "Product Test Name #{i}" }

    factory :static_filter_test do
      name { 'Static Result' }
      _type { 'FilteringTest' }
      options { { 'filters' => { 'genders' => ['F'] } } }
      expected_result = { '40280382-5FA6-FE85-0160-0918E74D2075' =>
                          { 'PopulationCriteria1' =>
                            { 'measure_id' => '40280382-5FA6-FE85-0160-0918E74D2075',
                              'nqf_id' => '0024',
                              'effective_date' => 1_514_764_799,
                              'filters' => nil,
                              'IPP' => 1,
                              'DENOM' => 1,
                              'NUMER' => 0,
                              'antinumerator' => 1,
                              'DENEX' => 0,
                              'DENEXCEP' => 0,
                              'MSRPOPL' => 0,
                              'considered' => 1,
                              'execution_time' => 1,
                              'pop_set_hash' => { population_set_id: 'PopulationCriteria1' },
                              'supplemental_data' => { 'IPP' => { 'RACE' => { '1002-5' => 1 },
                                                                  'ETHNICITY' => { '2186-5' => 1 },
                                                                  'SEX' => { 'F' => 1 },
                                                                  'PAYER' => { '1' => 1 } },
                                                       'DENOM' => { 'RACE' => { '1002-5' => 1 },
                                                                    'ETHNICITY' => { '2186-5' => 1 },
                                                                    'SEX' => { 'F' => 1 },
                                                                    'PAYER' => { '1' => 1 } },
                                                       'NUMER' => {},
                                                       'DENEX' => {} } } } }
      expected_results { expected_result }

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
      end
    end
  end
end
