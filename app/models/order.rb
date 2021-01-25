class Order < ApplicationRecord
  belongs_to :ordering_org, class_name: 'Org', inverse_of: :orders_to_order
  belongs_to :buying_org, class_name: 'Org', inverse_of: :orders_to_buy, optional: true
  has_one :actual_unit, dependent: :destroy
  enum shop_type: ShopType.to_activerecord_enum
  enum status: {
    before_order: 1,
    ordered: 2,
    buying: 3,
    shipped: 4
  }

  validate :ordering_org?
  validate :buying_org?

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
end
