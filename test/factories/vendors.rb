FactoryGirl.define do
  factory :vendor, class: Vendor do

    sequence(:name) { |i| "Tester #{i}" }

    factory :vendor_with_pocs do
      pocs { [FactoryGirl.build(:poc), FactoryGirl.build(:poc)] }
    end

    factory :vendor_no_name do
      name ""
    end

    factory :vendor_nil_name do
      name nil
    end

    factory :vendor_static_name do
      name "Name 1"
    end

    # with pocs

    factory :vendor_with_pocs_with_no_name do 
      pocs { [FactoryGirl.build(:poc_no_name)] }
    end

    factory :vendor_with_pocs_same_name do
      pocs { [FactoryGirl.build(:poc1), FactoryGirl.build(:poc1)] }
    end

    factory :vendor_with_many_pocs do
      temp = []
      (0..1000).each do |i|
        temp.push(FactoryGirl.build(:poc))
      end
      pocs { temp }
    end

  end
end