# frozen_string_literal: true

FactoryBot.define do
  factory :provider, class: Provider do
    sequence(:givenNames) { |i| ["Given_Name #{i}"] }
    sequence(:familyName) { |i| ["Family_Name #{i}"] }
    specialty { '200000000X' }
    trait :default do
      ids do
        [QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.6', value: '020700270'),
         QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.2', value: '1520670765'),
         QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.336', value: '563358')]
      end
      addresses { [{ 'street' => ['202 Burlington Rd'], 'city' => 'Bedford', 'state' => 'MA', 'zip' => '01730', 'country' => 'US' }] }
    end

    trait :tin do
      ids do
        [QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.6', value: '1520670765'),
         QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.2', value: '897230473'),
         QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.336', value: '563358')]
      end
    end

    trait :npi do
      ids do
        [QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.6', value: '1480614951'),
         QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.2', value: '020700270'),
         QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.336', value: '563358')]
      end
    end

    trait :combination do
      ids do
        [QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.6', value: '1520670765'),
         QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.2', value: '020700270'),
         QDM::Identifier.new(namingSystem: '2.16.840.1.113883.4.336', value: '563358')]
      end
      addresses { [{ 'street' => ['100 Bureau Drive'], 'city' => 'Gaithersburg', 'state' => 'MD', 'zip' => '20899', 'country' => 'US' }] }
    end

    factory :default_provider, traits: [:default]
    factory :tin_provider, traits: [:tin]
    factory :combination_provider, traits: [:combination]
    factory :npi_provider, traits: [:npi]
  end
end
