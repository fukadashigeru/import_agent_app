class ActualUnit < ApplicationRecord
  belongs_to :order
  has_many :actual_unit_urls, dependent: :destroy
end
