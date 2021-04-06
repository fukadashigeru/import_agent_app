class EcShop < ApplicationRecord
  belongs_to :org, inverse_of: :ec_shops
  has_many :suppliers, dependent: :restrict_with_error, inverse_of: :ec_shop
  has_many :orders, dependent: :restrict_with_error, inverse_of: :ec_shop
  enum ec_shop_type: EcShopType.to_activerecord_enum
end
