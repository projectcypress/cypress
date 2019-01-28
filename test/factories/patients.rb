# Requires a bundleId to be passed in as a string, not a BSON Object

FactoryBot.define do
  factory :patient, class: Patient do
    transient do
      seq_id { 1 }
    end

    familyName { 'MPL record' }
    givenNames { [seq_id.to_s] }
    medical_record_number {"#{seq_id}989db70-4d42-0135-8680-20999b0ed66f"}
    insurance_provider_hash = { 'codes' => { 'SOP' => ['349'] },
                                'name' => 'Other',
                                'type' => 'OT',
                                'payer' => { 'name' => 'Other' },
                                'financial_responsibility_type' => { 'code' => 'SELF', 'codeSystem' => 'HL7 Relationship Code' },
                                'member_id' => '1374589940',
                                'start_time' => '1949-05-23T13:24:00+00:00' }
    insurance_providers { [insurance_provider_hash] }
    qdmPatient { FactoryBot.build(:qdm_patient) }

    after(:create) do |patient|
      provider = create(:default_provider)
      create(:individual_bundle_result, patient_id: patient._id, bundleId: patient.bundleId)
      patient.provider_performances << CQM::ProviderPerformance.new(provider: provider)
      patient.save!
    end

    factory :static_test_patient do
      familyName { 'A' }
      givenNames { ['Dental_Peds'] }
      qdmPatient { FactoryBot.build(:qdm_patient) }

      after(:create) do |patient|
        provider = create(:default_provider)
        patient.provider_performances << CQM::ProviderPerformance.new(provider: provider)
        patient.save!
      end
    end
  end
end
