class ActualUnit < ApplicationRecord
  belongs_to :order
  has_many :actual_unit_urls, dependent: :destroy
  has_many :supplier_urls, through: :actual_unit_urls
end
