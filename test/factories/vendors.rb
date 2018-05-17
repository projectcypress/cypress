FactoryBot.define do
  factory :vendor, class: Vendor do
    sequence(:name) { |i| "Vendor Name #{i}" }

    factory :vendor_with_poc do
      points_of_contact { [FactoryBot.build(:poc)] }
    end

    factory :vendor_with_points_of_contact do
      points_of_contact { [FactoryBot.build(:poc), FactoryBot.build(:poc)] }
    end

    factory :vendor_no_name do
      name ''
    end

    factory :vendor_static_name do
      name 'Vendor Same Name'
    end

    # with points_of_contact

    factory :vendor_with_points_of_contact_with_no_name do
      points_of_contact { [FactoryBot.build(:poc_no_name)] }
    end

    factory :vendor_with_points_of_contact_same_name do
      points_of_contact { [FactoryBot.build(:poc1), FactoryBot.build(:poc1)] }
    end

    factory :vendor_with_many_points_of_contact do
      temp = []
      1000.times do
        temp.push(FactoryBot.build(:poc))
      end
      points_of_contact { temp }
    end
  end
end
