class Org < ApplicationRecord
  has_many :orders_to_order, class_name: 'Order', foreign_key: :ordering_org_id
  has_many :orders_to_buy, class_name: 'Order', foreign_key: :buying_org_id
end
