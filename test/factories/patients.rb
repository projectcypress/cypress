# Requires a bundleId to be passed in as a string, not a BSON Object

FactoryBot.define do
  factory :patient, class: BundlePatient do
    transient do
      seq_id { 1 }
    end

    medical_record_number { "#{seq_id}989db70-4d42-0135-8680-20999b0ed66f" }
    insurance_provider_hash = { 'codes' => { 'SOP' => ['349'] },
                                'name' => 'Other',
                                'type' => 'OT',
                                'payer' => { 'name' => 'Other' },
                                'financial_responsibility_type' => { 'code' => 'SELF', 'codeSystem' => 'HL7 Relationship Code' },
                                'member_id' => '1374589940',
                                'start_time' => '1949-05-23T13:24:00+00:00' }
    insurance_providers { [insurance_provider_hash] }

    factory :static_bundle_patient, class: BundlePatient do
      familyName { 'MPL record' }
      givenNames { [seq_id.to_s] }
      qdmPatient { FactoryBot.build(:qdm_patient) }

      after(:create) do |patient|
        provider = create(:default_provider)
        cr = create(:individual_bundle_result, patient_id: patient._id, correlation_id: patient.bundleId)
        cr.individual_results.each_pair do |_pop_key, individual_result|
          individual_result['patient_id'] = patient.qdmPatient.id.to_s
          individual_result['measure_id'] = cr.measure_id.to_s
        end
        cr.save
        cr_cv = create(:individual_bundle_cv_result, patient_id: patient._id, correlation_id: patient.bundleId)
        cr_cv.individual_results.each_pair do |_pop_key, individual_result|
          individual_result['patient_id'] = patient.qdmPatient.id.to_s
          individual_result['measure_id'] = cr_cv.measure_id.to_s
        end
        cr_cv.save
        patient.provider_performances << CQM::ProviderPerformance.new(provider: provider)
        patient.save!
      end
    end

    factory :static_test_patient, class: ProductTestPatient do
      familyName { 'A' }
      givenNames { ['Dental_Peds'] }
      qdmPatient { FactoryBot.build(:qdm_patient) }

      after(:create) do |patient|
        provider = create(:default_provider)
        patient.provider_performances << CQM::ProviderPerformance.new(provider: provider)
        patient.save!
      end
    end

    factory :vendor_test_patient, class: VendorPatient do
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
