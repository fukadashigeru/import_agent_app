FactoryBot.define do
  factory :org do
    sequence(:name) { |n| "TEST_NAME#{n}" }
  end
end
