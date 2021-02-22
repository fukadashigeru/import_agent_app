FactoryBot.define do
  factory :actual_unit_url do
    association :actual_unit
    association :supplier_url
  end
end
