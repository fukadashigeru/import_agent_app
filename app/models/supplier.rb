class Supplier < ApplicationRecord
  belongs_to :org
  has_many :orders, dependent: :restrict_with_error, inverse_of: :supplier
  has_many :optional_units, dependent: :destroy, inverse_of: :supplier
  enum shop_type: ShopType.to_activerecord_enum
end
