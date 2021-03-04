class Order < ApplicationRecord
  belongs_to :ec_shop, inverse_of: :orders
  has_one :ordering_org, through: :ec_shop,
                         source: :org,
                         class_name: 'Org',
                         inverse_of: :orders_to_order
  belongs_to :supplier, inverse_of: :orders
  # belongs_to :supplier, inverse_of: :orders, optional: true
  belongs_to :buying_org, class_name: 'Org', inverse_of: :orders_to_buy, optional: true
  has_one :actual_unit, dependent: :destroy, inverse_of: :order
  enum status: {
    before_order: 1,
    ordered: 2,
    buying: 3,
    shipped: 4
  }

  validate :ordering_org?
  validate :buying_org?
  # validate :validate_trade_no
  scope :ec_shop_is, lambda { |ec_shop_type|
    ec_shop = EcShop.where(ec_shop_type: ec_shop_type)
    joins(:ec_shop).merge(ec_shop)
  }

  # scope :having_actual_unit, -> { select(&:actual_unit) }
  scope :having_actual_unit, lambda {
    ids = ActualUnit.select(:order_id)
    where(id: ids)
  }

  # scope :having_no_actual_unit, -> { select { |order| order.actual_unit.nil? } }
  scope :having_no_actual_unit, lambda {
    ids = ActualUnit.select(:order_id)
    where.not(id: ids)
  }

  def status_i18n
    I18n.t status, scope: %i[enum orders status]
  end

  private

  def ordering_org?
    return if ordering_org.ordering_org?

    errors.add(:base, :not_ordering_org)
  end

  def buying_org?
    return if buying_org.nil? || buying_org.buying_org?

    errors.add(:base, :not_buying_org)
  end

  # def validate_trade_no
  #   return if ordering_org.orders.where(shop_type: shop_type, trade_no: trade_no).empty?

  #   errors.add(:base, '取引IDが既に登録されています。')
  # end
end
