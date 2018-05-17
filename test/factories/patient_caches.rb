FactoryBot.define do
  factory :patient_cache, class: HealthDataStandards::CQM::PatientCache do
    transient do
      patient_id nil
      medical_record_id nil
    end
    value { FactoryBot.build(:patient_cache_value, patient_id: patient_id, medical_record_id: medical_record_id) }
  end
end
