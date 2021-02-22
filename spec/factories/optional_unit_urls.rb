FactoryBot.define do
  factory :optional_unit_url do
    supplier_url { nil }
    optional_unit { nil }
  end
end
