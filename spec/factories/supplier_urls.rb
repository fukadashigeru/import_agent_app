FactoryBot.define do
  factory :supplier_url do
    url { 'MyString' }
    is_have_stock { false }
    association :org
  end
end
