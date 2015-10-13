FactoryGirl.define do
  factory :poc, class: PointOfContact do
    sequence(:name) { |i| "Contact #{i}" }
    sequence(:email) { |i| "contact#{i}@example.com" }
    phone '1(222)333-4444'
    contact_type 'Admin'
    sequence(:id) { |i| i }

    factory :poc1 do
      name 'poc1'
    end

    factory :poc_no_name do
      name nil
    end
  end
end
