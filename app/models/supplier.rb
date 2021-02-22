class Supplier < ApplicationRecord
  belongs_to :org
  belongs_to :first_priority_unit, class_name: 'OptionalUnit', inverse_of: :fpu_supplier, optional: true
  has_many :orders, dependent: :restrict_with_error, inverse_of: :supplier
  has_many :optional_units, dependent: :destroy, inverse_of: :supplier
  enum shop_type: ShopType.to_activerecord_enum
end
