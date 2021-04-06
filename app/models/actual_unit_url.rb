class ActualUnitUrl < ApplicationRecord
  belongs_to :supplier_url, inverse_of: :actual_unit_urls
  belongs_to :actual_unit, inverse_of: :actual_unit_urls
end
