FactoryBot.define do
  factory :product_test, class: MeasureTest do
    sequence(:name) { |i| "Product Test Name #{i}" }

    factory :product_test_static_result do
      name 'Static Result'
      _type 'MeasureTest'
      cms_id 'CMS1234'
      aug_record = [{ 'original_patient_id' => '',
                      'medical_record_number' =>  '1234',
                      'first' =>  %w[Dental_Peds Denial_Peds],
                      'last' =>  %w[A A],
                      'gender' =>  %w[M M] }]
      augmented_patients { aug_record }
      expected_result = { 'BE65090C-EB1F-11E7-8C3F-9A214CF093AEa' =>
                          { 'measure_id' => 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE',
                            'sub_id' => 'a',
                            'nqf_id' => '0024',
                            'effective_date' => 1_293_840_000,
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
                            'population_ids' => { 'IPP' => 'F2666FD4-EB1F-11E7-8C3F-9A214CF093AE',
                                                  'DENOM' => 'F7D7DC82-EB1F-11E7-8C3F-9A214CF093AE',
                                                  'NUMER' => 'FC6D029A-EB1F-11E7-8C3F-9A214CF093AE',
                                                  'DENEX' => '0163BB04-EB20-11E7-8C3F-9A214CF093AE' },
                            'supplemental_data' => { 'IPP' => { 'RACE' => { '1002-5' => 1 },
                                                                'ETHNICITY' => { '2186-5' => 1 },
                                                                'SEX' => { 'F' => 1 },
                                                                'PAYER' => { '1' => 1 } },
                                                     'DENOM' => { 'RACE' => { '1002-5' => 1 },
                                                                  'ETHNICITY' => { '2186-5' => 1 },
                                                                  'SEX' => { 'F' => 1 },
                                                                  'PAYER' => { '1' => 1 } },
                                                     'NUMER' => {},
                                                     'DENEX' => {} } } }
      expected_results { expected_result }
      measure_ids ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
      association :product, :factory => :product_static_bundle
      after(:create) do |pt|
        extended_data = { 'correlation_id' => pt.id,
                          'medical_record_number' => '1989db70-4d42-0135-8680-30999b0ed66f',
                          'insurance_providers' => '[{"codes":{"SOP":["349"]},"name":"Other","type":"OT","payer":{"name":"Other"},"financial_responsibility_type":{"code":"SELF","codeSystem":"HL7 Relationship Code"},"member_id":"1374589940","start_time":"1949-05-23T13:24:00+00:00"}]'}
        patient = create(:static_test_patient, 'bundleId' => pt.bundle._id, 'extendedData' => extended_data)
        patient.save
        aug_record[0]['original_patient_id'] = patient._id
        pt.augmented_patients = aug_record
        pt.save
      end
    end
  end
end
