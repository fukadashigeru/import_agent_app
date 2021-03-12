class OptionalUnit < ApplicationRecord
  belongs_to :supplier, inverse_of: :optional_units
  has_many :optional_unit_urls, dependent: :destroy, inverse_of: :optional_unit
  has_many :supplier_urls, through: :optional_unit_urls
  has_one :fpu_supplier,
          class_name: 'Supplier',
          foreign_key: :first_priority_unit_id,
          dependent: :nullify,
          inverse_of: :first_priority_unit
end
