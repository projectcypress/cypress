FactoryBot.define do
  factory :product_test, class: MeasureTest do
    sequence(:name) { |i| "Product Test Name #{i}" }

    factory :product_test_static_result do
      name 'Static Result'
      _type 'MeasureTest'
      cms_id 'CMS1234'
      aug_record = [{ medical_record_number: '1234',
                      first: %w[Dental_Peds Denial_Peds],
                      last: %w[A A],
                      gender: %w[M M] }]
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
        create(:static_test_record, :test_id => pt._id)
      end
    end
  end
end
