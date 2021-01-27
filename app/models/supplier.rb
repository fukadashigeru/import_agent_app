class Supplier < ApplicationRecord
  belongs_to :org
  has_many :optional_units, dependent: :destroy, inverse_of: :supplier
end
