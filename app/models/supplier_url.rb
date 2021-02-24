class SupplierUrl < ApplicationRecord
  belongs_to :org
  has_many :actual_unit_urls, dependent: :destroy, inverse_of: :supplier_url
  has_many :optional_unit_urls, dependent: :destroy, inverse_of: :supplier_url
end
