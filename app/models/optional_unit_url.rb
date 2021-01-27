class OptionalUnitUrl < ApplicationRecord
  belongs_to :supplier_url, inverse_of: :optiona_unit_url
  belongs_to :optional_unit, inverse_of: :optiona_unit_url
end
