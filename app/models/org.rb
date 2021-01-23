class Org < ApplicationRecord
  has_many :orders_to_order, class_name: 'Order', foreign_key: :ordering_org_id, dependent: :restrict_with_error, inverse_of: :ordering_org
  has_many :orders_to_buy, class_name: 'Order', foreign_key: :buying_org_id, dependent: :restrict_with_error, inverse_of: :buying_org
end
