FactoryBot.define do
  factory :user do
    name { 'MyString' }
    email { Faker::Internet.unique.email }
    password { 'password' }
    password_confirmation { 'password' }
    agreed_at { Time.zone.now }
  end
end
