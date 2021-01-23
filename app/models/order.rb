class Order < ApplicationRecord
  belongs_to :ordering_org, class_name: 'Org', inverse_of: :orders_to_order
  belongs_to :buying_org, class_name: 'Org', inverse_of: :orders_to_buy
  enum status: {
    before_order: 1,
    ordered: 2,
    buying: 3,
    shipped: 4
  }

  def status_i18n
    I18n.t status, scope: %i[enum orders status]
  end
end
