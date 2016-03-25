FactoryGirl.define do
  factory :user do
    email 'test@mitre.org'
    password 'Cypre$$v3'
    terms_and_conditions '1'
  end
end
