class ActualUnit < ApplicationRecord
  belongs_to :order, inverse_of: :actual_unit
  has_many :actual_unit_urls, dependent: :destroy, inverse_of: :actual_unit
  has_many :supplier_urls, through: :actual_unit_urls, inverse_of: :actual_unit

  scope :order_is, ->(order) { where(order: order) }
end
