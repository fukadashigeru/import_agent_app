FactoryBot.define do
  factory :user_registerer do
    email { Faker::Internet.unique.email }
  end
end
