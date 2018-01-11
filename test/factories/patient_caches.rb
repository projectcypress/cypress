FactoryGirl.define do
  factory :patient_cache, class: HealthDataStandards::CQM::PatientCache do
    value { FactoryGirl.build(:patient_cache_value) }
  end
end
