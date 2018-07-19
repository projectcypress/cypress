FactoryBot.define do
  factory :query_cache, class: HealthDataStandards::CQM::QueryCache do
    calculation_date Time.now.in_time_zone

    factory :static_query_cache do
      population_ids_hash = { 'IPP' => 'EA122D3D-5348-43DB-96A5-2D044ACAAA4D',
                              'DENOM' => 'C7A5DF86-5533-48EA-A9C6-04A3F5DB6BE9',
                              'NUMER' => 'D285D0D1-0AB5-4228-A5A3-F3DE5952F4AF',
                              'DENEX' => '0C45DCFF-89D6-4ECF-90C3-2D9B0EE91279' }
      supplemental_data_hash = { 'IPP' => { 'RACE' => { '1002-5' => 1 },
                                            'ETHNICITY' => { '2186-5' => 1 },
                                            'SEX' => { 'F' => 1 },
                                            'PAYER' => { '1' => 1 } },
                                 'DENOM' => { 'RACE' => { '1002-5' => 1 },
                                              'ETHNICITY' => { '2186-5' => 1 },
                                              'SEX' => { 'F' => 1 },
                                              'PAYER' => { '1' => 1 } },
                                 'NUMER' => {},
                                 'DENEX' => {} }
      IPP 1
      DENOM 1
      NUMER 0
      DENEX 0
      DENEXCEP 0
      MSRPOPL 0
      measure_id 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'
      population_ids population_ids_hash
      supplemental_data supplemental_data_hash
      effective_date 1_356_998_399
    end
  end
end
