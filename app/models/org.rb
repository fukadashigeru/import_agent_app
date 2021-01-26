class Org < ApplicationRecord
  has_many :orders_to_order, class_name: 'Order',
                             foreign_key: :ordering_org_id,
                             dependent: :restrict_with_error,
                             inverse_of: :ordering_org
  has_many :orders_to_buy, class_name: 'Order',
                           foreign_key: :buying_org_id,
                           dependent: :restrict_with_error,
                           inverse_of: :buying_org
  enum org_type: {
    ordering_org: 1,
    buying_org: 2
  }

  def org_type_i18n
    I18n.t org_type, scope: %i[enum orgs org_type]
  end
end
