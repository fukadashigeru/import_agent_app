class Order
  class OrderRepository < ApplicationStruct
    attribute :org, Types::Instance(Org)
    attribute :shop_type, Types::Symbol.enum(:ordering_org, :buying_org)
    attribute :status, Types::Array.of(Types::Symbol)
    attribute :order_by, Types::Symbol.enum(:asc, :desc)

    def orders
      case shop_type
      when :ordering_org
        @orders ||= org
                    .orders_to_order
                    .where(status: [status])
                    .order(created_at: order_by)
                    .includes(actual_unit: { actual_unit_urls: :supplier_url })
      when :buying_org
        @orders ||= org
                    .orders_to_buy
                    .where(status: [status])
                    .order(created_at: order_by)
                    .includes(actual_unit: { actual_unit_urls: :supplier_url })
      end
    end

    # def actual_units
    #   # @actual_unit ||= orders.map(&:actual_unit).zip(orders).to_h
    #   @actual_unit ||= orders.map(&:actual_unit).index_by(&:order)
    # end
  end
end
