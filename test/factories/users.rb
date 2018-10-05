FactoryBot.define do
  factory :user, class: User do
    email { 'test@test.com' }
    password { 'Cypre$$v3' }
    terms_and_conditions { '1' }

    factory :admin_user do
      id { '4def93dd4f85cf8968000010' }
      email { 'admin@test.com' }
      password { 'Cypre$$v3' }
      terms_and_conditions { '1' }

      after(:create) do |user|
        create(:role, user_ids: [user._id], name: 'admin')
      end
    end

    factory :atl_user do
      id { '4def93dd4f85cf8968000001' }
      email { 'atl@test.com' }
      password { 'Cypre$$v3' }
      terms_and_conditions { '1' }

      after(:create) do |user|
        create(:role, user_ids: [user._id], name: 'atl')
      end
    end

    factory :user_user do
      id { '4def93dd4f85cf8968000002' }
      email { 'user@test.com' }
      password { 'Cypre$$v3' }
      terms_and_conditions { '1' }
      after(:create) do |user|
        create(:role, user_ids: [user._id], name: 'owner')
      end
    end

    factory :vendor_user do
      id { '4def93dd4f85cf8968000003' }
      email { 'vendor@test.com' }
      password { 'Cypre$$v3' }
      terms_and_conditions { '1' }

      after(:create) do |user|
        user.role_ids = []
        user.save
      end
    end

    factory :other_user do
      id { '4def93dd4f85cf8968000004' }
      email { 'other@test.com' }
      password { 'Cypre$$v3' }
      terms_and_conditions { '1' }

      after(:create) do |user|
        user.role_ids = []
        user.save
      end
    end
  end
end
