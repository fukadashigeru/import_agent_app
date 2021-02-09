class OptionalUnit < ApplicationRecord
  belongs_to :supplier
  has_many :optional_unit_urls, dependent: :destroy, inverse_of: :optional_unit
  has_many :supplier_urls, through: :optional_unit_urls
end
