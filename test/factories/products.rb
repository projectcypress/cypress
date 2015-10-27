FactoryGirl.define do
  factory :product, class: Product do
    sequence(:name) { |i| "Product Name #{i}" }

    factory :product_no_name do
      name ''
    end

    factory :product_static_name do
      name 'Product Same Name'
    end
  end
end
