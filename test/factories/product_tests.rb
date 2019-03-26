FactoryBot.define do
  factory :product_test, class: MeasureTest do
    sequence(:name) { |i| "Product Test Name #{i}" }

    factory :product_test_static_result do
      name { 'Static Result' }
      _type { 'MeasureTest' }
      cms_id { 'CMS1234' }
      aug_record = [{ 'original_patient_id' => '123',
                      'medical_record_number' => '1234',
                      'first' => %w[Dental_Peds Denial_Peds],
                      'last' => %w[A A],
                      'gender' => %w[M M] }]
      augmented_patients { aug_record }
      expected_result = { '40280382-5FA6-FE85-0160-0918E74D2075' =>
                          { 'PopulationCriteria1' =>
                            { 'measure_id' => '40280382-5FA6-FE85-0160-0918E74D2075',
                              'nqf_id' => '0024',
                              'effective_date' => 1_514_764_799,
                              'test_id' => { 'oid' => '51703a6a3054cf8439000044' },
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
      association :provider, factory: :default_provider
      association :product, factory: :product_static_bundle
      after(:create) do |pt|
        patient = create(:static_test_patient, 'bundleId' => pt.bundle._id)
        patient.correlation_id = pt.id
        patient.medical_record_number = '1989db70-4d42-0135-8680-30999b0ed66f'
        insurance_provider_hash = { 'codes' => { 'SOP' => ['349'] },
                                    'name' => 'Other',
                                    'type' => 'OT',
                                    'payer' => { 'name' => 'Other' },
                                    'financial_responsibility_type' => { 'code' => 'SELF', 'codeSystem' => 'HL7 Relationship Code' },
                                    'member_id' => '1374589940',
                                    'start_time' => '1949-05-23T13:24:00+00:00' }
        patient.insurance_providers = [insurance_provider_hash]
        patient.save
        aug_record[0]['original_patient_id'] = patient._id
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'cqm_patient' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1',
               'IPP' => 0,
               'DENOM' => 0,
               'DENEX' => 0,
               'NUMER' => 0)
        pt.augmented_patients = aug_record
        pt.save
      end
    end

    factory :cv_product_test_static_result do
      name { 'Static Result' }
      _type { 'MeasureTest' }
      cms_id { 'CMS1234' }
      aug_record = [{ 'original_patient_id' => '123',
                      'medical_record_number' => '1234',
                      'first' => %w[Dental_Peds Denial_Peds],
                      'last' => %w[A A],
                      'gender' => %w[M M] }]
      augmented_patients { aug_record }
      expected_result = { 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE' =>
                          { 'PopulationCriteria1' =>
                            { 'measure_id' => 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE',
                              'nqf_id' => '0024',
                              'effective_date' => 1_514_764_799,
                              'test_id' => { 'oid' => '51703a6a3054cf8439000044' },
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
      measure_ids { ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }
      association :provider, factory: :default_provider
      association :product, factory: :product_static_bundle
      after(:create) do |pt|
        patient = create(:static_test_patient, 'bundleId' => pt.bundle._id)
        patient.correlation_id = pt.id
        patient.medical_record_number = '1989db70-4d42-0135-8680-30999b0ed66f'
        insurance_provider_hash = { 'codes' => { 'SOP' => ['349'] },
                                    'name' => 'Other',
                                    'type' => 'OT',
                                    'payer' => { 'name' => 'Other' },
                                    'financial_responsibility_type' => { 'code' => 'SELF', 'codeSystem' => 'HL7 Relationship Code' },
                                    'member_id' => '1374589940',
                                    'start_time' => '1949-05-23T13:24:00+00:00' }
        patient.insurance_providers = [insurance_provider_hash]
        patient.save
        aug_record[0]['original_patient_id'] = patient._id
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'cqm_patient' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1',
               'IPP' => 1,
               'MSRPOPL' => 1,
               'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'cqm_patient' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 1',
               'IPP' => 0,
               'MSRPOPL' => 0,
               'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'cqm_patient' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 2',
               'IPP' => 0,
               'MSRPOPL' => 0,
               'MSRPOPLEX' => 0)
        create(:cqm_individual_result,
               'correlation_id' => pt.id.to_s,
               'patient_id' => patient.id,
               'cqm_patient' => patient.id,
               'measure_id' => pt.measures.first.id,
               'population_set_key' => 'PopulationCriteria1 - Stratification 3',
               'IPP' => 1,
               'MSRPOPL' => 1,
               'MSRPOPLEX' => 0)
        pt.augmented_patients = aug_record
        pt.save
      end
    end
  end
end
