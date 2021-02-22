class SupplierUrl < ApplicationRecord
  belongs_to :org
  has_many :actual_unit_urls, dependent: :destroy
  has_many :optional_unit_urls, dependent: :destroy
end
