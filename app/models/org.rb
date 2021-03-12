class Org < ApplicationRecord
  has_many :ec_shops, dependent: :restrict_with_error
  has_many :orders_to_order, through: :ec_shops,
                             source: :orders,
                             class_name: 'Order',
                             inverse_of: :ordering_org
  has_many :orders_to_buy, class_name: 'Order',
                           foreign_key: :buying_org_id,
                           dependent: :restrict_with_error,
                           inverse_of: :buying_org
  has_many :suppliers, through: :ec_shops, source: :suppliers
  has_many :supplier_urls, dependent: :destroy
  enum org_type: {
    ordering_org: 1,
    buying_org: 2
  }

  def org_type_i18n
    I18n.t org_type, scope: %i[enum orgs org_type]
  end
end
