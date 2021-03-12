class Order
  class OrdersRepository < ApplicationStruct
    attribute :org, Types::Instance(Org)
    attribute :status, Types::Array.of(Types::Symbol)
    attribute :order_by, Types::Symbol.enum(:asc, :desc)

    def orders
      case org.org_type.to_sym
      when :ordering_org
        orders_to_order
      when :buying_org
        orders_to_buy
      end
    end

    def orders_to_order
      @orders_to_order ||= org
                           .orders_to_order
                           .where(status: [status])
                           .order(created_at: order_by)
                           .includes(:supplier, actual_unit: { actual_unit_urls: :supplier_url })
    end

    def orders_to_buy
      @orders_to_buy ||= org
                         .orders_to_buy
                         .where(status: [status])
                         .order(created_at: order_by)
                         .includes(actual_unit: { actual_unit_urls: :supplier_url })
    end

    # def actual_units
    #   # @actual_unit ||= orders.map(&:actual_unit).zip(orders).to_h
    #   @actual_unit ||= orders.map(&:actual_unit).index_by(&:order)
    # end
  end
end
