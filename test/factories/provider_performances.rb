FactoryBot.define do
  factory :provider_performance, class: CQM::ProviderPerformance do
    association :provider, factory: :default_provider
  end
end
