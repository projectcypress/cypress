# frozen_string_literal: true

FactoryBot.define do
  factory :role, class: Role do
    name { 'user' }
    resource { nil }
  end
end
