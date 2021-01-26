class SupplierUrl < ApplicationRecord
  belongs_to :org
  has_many :actual_unit_urls, dependent: :destroy
end
