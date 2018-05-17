FactoryBot.define do
  factory :value_set, class: HealthDataStandards::SVS::ValueSet do
    sequence(:display_name) { |i| "Value Set Name #{i}" }
    sequence(:oid) { |i| "1.#{i}.#{i + 1}.#{i + 2}" }
    sequence(:concepts) { |i| [{ 'code' => (i * (i + 1) * (i + 2)).to_s, 'code_system' => '2.16.840.1.113883.6.96', 'code_system_name' => 'SNOMED-CT' }] }

    factory :value_set_payer do
      display_name 'Payer'
      oid '2.16.840.1.114222.4.11.3591'
      payer_codes = [{ 'code' => '1', 'code_system' => '2.16.840.1.113883.3.221.5' },
                     { 'code' => '2', 'code_system' => '2.16.840.1.113883.3.221.5' },
                     { 'code' => '349', 'code_system' => '2.16.840.1.113883.3.221.5' }]
      concepts { payer_codes }
    end
  end
end
