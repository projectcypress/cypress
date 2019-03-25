FactoryBot.define do
  factory :value_set, class: ValueSet do
    transient do
      seq_id { 1 }
    end

    display_name { "Value Set Name #{seq_id}" }
    oid { "1.#{seq_id}.#{seq_id + 1}.#{seq_id + 2}" }
    version { '123' }
    concepts { [{ 'code' => (seq_id * (seq_id + 1) * (seq_id + 2)).to_s, 'code_system_oid' => '2.16.840.1.113883.6.96', 'code_system_name' => 'SNOMED-CT', 'display_name' => "Concept #{seq_id}" }] }

    factory :value_set_payer do
      display_name { 'Payer' }
      oid { '2.16.840.1.114222.4.11.3591' }
      payer_codes = [{ 'code' => '1', 'code_system_oid' => '2.16.840.1.113883.3.221.5' },
                     { 'code' => '2', 'code_system_oid' => '2.16.840.1.113883.3.221.5' },
                     { 'code' => '349', 'code_system_oid' => '2.16.840.1.113883.3.221.5' }]
      concepts { payer_codes }
    end

    factory :direct_reference_code do
      code_system_version = 'urn:hl7:version:2013-09'
      code_system_name = 'SNOMED-CT'
      name = 'Patient deceased during stay (discharge status = dead) (finding)'
      code = '1000'
      display_name { 'DRC' }
      code_hash = 'drc-' + Digest::SHA2.hexdigest("#{code_system_name} #{code} #{name} #{code_system_version}")
      oid { code_hash }
      drc_code = [{ 'code' => '1000', 'code_system_oid' => '2.16.840.1.113883.6.96' }]
      concepts { drc_code }
    end
  end
end
