FactoryGirl.define do
  factory :provider_performance, class: ProviderPerformance do
    association :provider, :factory => :default_provider
  end
end
