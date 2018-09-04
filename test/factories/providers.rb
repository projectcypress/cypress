FactoryBot.define do
  factory :provider, class: Provider do
    sequence(:given_name) { |i| "Given_Name #{i}" }
    specialty '200000000X'
    trait :default do
      identifiers [{ 'namingSystem' => '2.16.840.1.113883.4.6', 'value' => '020700270' },
                   { 'namingSystem' => '2.16.840.1.113883.4.2', 'value' => '1520670765' },
                   { 'namingSystem' => '2.16.840.1.113883.4.336', 'value' => '563358' }]
      addresses [{ 'street' => ['202 Burlington Rd'], 'city' => 'Bedford', 'state' => 'MA', 'zip' => '01730', 'country' => 'US' }]
    end

    trait :tin do
      identifiers [{ 'namingSystem' => '2.16.840.1.113883.4.6', 'value' => '1520670765' },
                   { 'namingSystem' => '2.16.840.1.113883.4.2', 'value' => '897230473' },
                   { 'namingSystem' => '2.16.840.1.113883.4.336', 'value' => '563358' }]
    end

    trait :npi do
      identifiers [{ 'namingSystem' => '2.16.840.1.113883.4.6', 'value' => '1480614951' },
                   { 'namingSystem' => '2.16.840.1.113883.4.2', 'value' => '020700270' },
                   { 'namingSystem' => '2.16.840.1.113883.4.336', 'value' => '563358' }]
    end

    trait :combination do
      identifiers [{ 'namingSystem' => '2.16.840.1.113883.4.6', 'value' => '1520670765' },
                   { 'namingSystem' => '2.16.840.1.113883.4.2', 'value' => '020700270' },
                   { 'namingSystem' => '2.16.840.1.113883.4.336', 'value' => '563358' }]
      addresses [{ 'street' => ['100 Bureau Drive'], 'city' => 'Gaithersburg', 'state' => 'MD', 'zip' => '20899', 'country' => 'US' }]
    end

    factory :default_provider, traits: [:default]
    factory :tin_provider, traits: [:tin]
    factory :combination_provider, traits: [:combination]
    factory :npi_provider, traits: [:npi]
  end
end
