FactoryBot.define do
  factory :record, class: Record do
    sequence(:first) { |i| "Record Name #{i}" }

    factory :static_mpl_record do
      first 'MPL record'
      sequence(:last, &:to_s)
      gender 'F'
      birthdate 915_179_400
      sequence(:medical_record_number) { |i| "#{i}989db70-4d42-0135-8680-20999b0ed66f" }
      race_value = { 'code' => '1002-5',
                     'name' => 'American Indian or Alaska Native',
                     'codeSystem' => '2.16.840.1.113883.6.238' }
      race { race_value }
      ethnicity_value = { 'code' => '2186-5',
                          'name' => 'Not Hispanic or Latino',
                          'codeSystem' => '2.16.840.1.113883.6.238' }
      ethnicity { ethnicity_value }
      conditions [{ 'codes' => { 'SNOMED-CT' => ['210'] }, 'oid' => '2.16.840.1.113883.10.20.28.3.110' }]
      insurance_providers [{ 'name' => 'Medicare', 'type' => 'MA', 'codes' => { 'Source of Payment Typology' => ['1'] }, 'payer' => { 'name' => 'Medicare' } }]
      encounters [{ 'codes' => { 'SNOMED-CT' => ['60'] },
                    '_type' => 'Encounter',
                    'description' => 'Encounter, Performed=> Office Visit (Code List=> 2.16.840.1.113883.3.464.1003.101.12.1001',
                    'end_time' => 1_462_233_600,
                    'oid' => '2.16.840.1.113883.3.560.1.79',
                    'start_time' => 1_462_233_600,
                    'status_code' => { 'HL7 ActStatus' => ['performed'] } }]
      after(:create) do |rec|
        values = FactoryBot.build(:patient_cache_value, patient_id: rec._id)
        values['medical_record_id'] = rec.medical_record_number
        create(:patient_cache, value: values)
      end
    end

    factory :static_test_record do
      first 'Dental_Peds'
      last 'A'
      gender 'F'
      birthdate 915_179_400
      medical_record_number '1234'
      race_value = { 'code' => '1002-5',
                     'name' => 'American Indian or Alaska Native',
                     'codeSystem' => '2.16.840.1.113883.6.238' }
      race { race_value }
      ethnicity_value = { 'code' => '2186-5',
                          'name' => 'Not Hispanic or Latino',
                          'codeSystem' => '2.16.840.1.113883.6.238' }
      ethnicity { ethnicity_value }
      conditions [{ 'codes' => { 'SNOMED-CT' => ['210'] }, 'oid' => '2.16.840.1.113883.10.20.28.3.110' }]
      insurance_providers [{ 'name' => 'Medicare', 'type' => 'MA', 'codes' => { 'Source of Payment Typology' => ['1'] }, 'payer' => { 'name' => 'Medicare' } }]
      encounters [{ 'codes' => { 'SNOMED-CT' => ['60'] },
                    '_type' => 'Encounter',
                    'description' => 'Encounter, Performed=> Office Visit (Code List=> 2.16.840.1.113883.3.464.1003.101.12.1001',
                    'end_time' => 1_462_233_600,
                    'oid' => '2.16.840.1.113883.3.560.1.79',
                    'start_time' => 1_462_233_600,
                    'status_code' => { 'HL7 ActStatus' => ['performed'] } }]
      provider_performances { [FactoryBot.build(:provider_performance)] }
      after(:create) do |rec|
        values = FactoryBot.build(:patient_cache_value, patient_id: rec._id)
        values['test_id'] = rec.test_id
        values['medical_record_id'] = rec.medical_record_number
        create(:patient_cache, value: values)
      end
    end
  end
end
