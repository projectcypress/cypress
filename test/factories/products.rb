FactoryBot.define do
  factory :product, class: Product do
    sequence(:name) { |i| "Product Name #{i}" }

    factory :product_no_name do
      name { '' }
    end

    factory :product_static_name do
      name { 'Product Same Name' }
    end

    factory :static_product do
      name { 'Product Static Bundle' }
      description { 'Product Static Bundle' }
      trait :default do
        c1_test { true }
        c2_test { true }
        association :vendor, name: 'Static Bundle Vendor'
      end
      trait :no_c2 do
        c1_test { true }
        c2_test { false }
        association :vendor, name: '2015 Vendor No C2'
      end
      measure_ids { ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }
      association :bundle, factory: :static_bundle
      after(:create) do |p|
        p.add_checklist_test
        p.save
      end

      factory :product_static_bundle, traits: [:default]
      factory :product_no_c2, traits: [:no_c2]
    end
  end
end
