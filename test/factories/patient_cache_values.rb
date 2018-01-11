FactoryGirl.define do
  factory :patient_cache_value, class: HealthDataStandards::CQM::PatientCacheValue do
    IPP 1
    DENOM 1
    NUMER 0
    DENEXCEP 0
    DENEX 0
    antinumerator 1
    measure_id 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'
    sub_id 'a'
  end
end
