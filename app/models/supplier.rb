class Supplier < ApplicationRecord
  belongs_to :ec_shop, inverse_of: :suppliers
  has_one :org, through: :ec_shop,
                source: :org,
                class_name: 'Org',
                inverse_of: :suppliers
  belongs_to :first_priority_unit, class_name: 'OptionalUnit', inverse_of: :fpu_supplier, optional: true
  has_many :orders, dependent: :restrict_with_error, inverse_of: :supplier
  has_many :optional_units, dependent: :destroy, inverse_of: :supplier
end
