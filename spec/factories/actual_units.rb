FactoryBot.define do
  factory :actual_unit do
    association :org, factory: buying_org
  end
end
