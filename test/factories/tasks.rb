FactoryGirl.define do
  factory :task, class: Task do
    association :product_test, :factory => :product_test_static_result
  end
end
