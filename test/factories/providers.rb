FactoryGirl.define do
  factory :provider, class: Provider do
    sequence(:given_name) { |i| "Given_Name #{i}" }
    specialty '200000000X'
    trait :default do
      cda_identifiers [{ 'root' => '2.16.840.1.113883.4.6', 'extension' => '020700270' },
                       { 'root' => '2.16.840.1.113883.4.2', 'extension' => '1520670765' }]
      addresses [{ 'street' => ['202 Burlington Rd'], 'city' => 'Bedford', 'state' => 'MA', 'zip' => '01730', 'country' => 'US' }]
    end

    trait :tin do
      cda_identifiers [{ 'root' => '2.16.840.1.113883.4.6', 'extension' => '1520670765' },
                       { 'root' => '2.16.840.1.113883.4.2', 'extension' => '897230473' }]
    end

    trait :npi do
      cda_identifiers [{ 'root' => '2.16.840.1.113883.4.6', 'extension' => '1480614951' },
                       { 'root' => '2.16.840.1.113883.4.2', 'extension' => '020700270' }]
    end

    trait :combination do
      cda_identifiers [{ 'root' => '2.16.840.1.113883.4.6', 'extension' => '1520670765' },
                       { 'root' => '2.16.840.1.113883.4.2', 'extension' => '020700270' }]
      addresses [{ 'street' => ['100 Bureau Drive'], 'city' => 'Gaithersburg', 'state' => 'MD', 'zip' => '20899', 'country' => 'US' }]
    end

    factory :default_provider, traits: [:default]
    factory :tin_provider, traits: [:tin]
    factory :combination_provider, traits: [:combination]
    factory :npi_provider, traits: [:npi]
  end
end
