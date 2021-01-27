class OptionalUnitUrl < ApplicationRecord
  belongs_to :supplier_url, inverse_of: :optional_unit_urls
  belongs_to :optional_unit, inverse_of: :optional_unit_urls
end
