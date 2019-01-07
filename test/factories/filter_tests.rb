FactoryBot.define do
  factory :filter_test, class: FilteringTest do
    sequence(:name) { |i| "Product Test Name #{i}" }

    factory :static_filter_test do
      name { 'Static Result' }
      _type { 'FilteringTest' }
      options { { 'filters' => { 'genders' => ['F'] } } }
      expected_result = { 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE' =>
                          { 'measure_id' => 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE',
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
                            'population_ids' => { 'IPP' => 'EA122D3D-5348-43DB-96A5-2D044ACAAA4D',
                                                  'DENOM' => 'C7A5DF86-5533-48EA-A9C6-04A3F5DB6BE9',
                                                  'NUMER' => 'D285D0D1-0AB5-4228-A5A3-F3DE5952F4AF',
                                                  'DENEX' => '0C45DCFF-89D6-4ECF-90C3-2D9B0EE91279' },
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

      measure_ids { ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }
      association :product, :factory => :product_static_bundle
      after(:create) do |pt|
        extended_data = { 'correlation_id' => pt.id,
                          'medical_record_number' => '1989db70-4d42-0135-8680-30999b0ed66f',
                          'insurance_providers' => '[{"codes":{"SOP":["349"]},"name":"Other","type":"OT","payer":{"name":"Other"},"financial_responsibility_type":{"code":"SELF","codeSystem":"HL7 Relationship Code"},"member_id":"1374589940","start_time":"1949-05-23T13:24:00+00:00"}]' }
        patient = create(:static_test_patient, 'bundleId' => pt.bundle._id, 'extendedData' => extended_data)
        patient.save
        ir_extended_data = { 'correlation_id' => pt.id.to_s }
        create(:individual_result, 'extendedData' => ir_extended_data, 'patient_id' => patient.id, 'measure_id' => pt.measures.first.id)
      end
    end
  end
end
