class Supplier < ApplicationRecord
  belongs_to :ec_shop, inverse_of: :suppliers
  has_one :org, through: :ec_shop,
                source: :org,
                class_name: 'Org',
                inverse_of: :suppliers
  belongs_to :first_priority_unit, class_name: 'OptionalUnit', inverse_of: :fpu_supplier, optional: true
  has_many :orders, dependent: :restrict_with_error, inverse_of: :supplier
  has_many :optional_units, dependent: :destroy, inverse_of: :supplier
  scope :ec_shop_is, lambda { |ec_shop_type|
    ec_shop = EcShop.where(ec_shop_type: ec_shop_type)
    joins(:ec_shop).merge(ec_shop)
  }

  def all_supplier_urls_is_same?
    return nil unless first_priority_unit

    first_supplier_url_ids = first_priority_unit.supplier_urls.ids.sort
    uniq_actual_supplier_urls.reject { |su| su.ids.sort == first_supplier_url_ids }.blank?
  end

  def uniq_actual_supplier_urls
    @uniq_actual_supplier_urls ||=
      orders
      .before_order
      .map { |order| indexed_supplier_urls_by_orders[order] }
      .uniq { |supplier_urls| supplier_urls.ids.sort }
  end

  def indexed_supplier_urls_by_orders
    @indexed_supplier_urls_by_orders ||=
      orders.index_with { |order| order.actual_unit&.supplier_urls }
  end
end
