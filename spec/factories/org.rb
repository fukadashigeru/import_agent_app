FactoryBot.define do
  factory :org do
    sequence(:name) { |n| "TEST_NAME#{n}" }
    org_type { :ordering_org }
  end
end
