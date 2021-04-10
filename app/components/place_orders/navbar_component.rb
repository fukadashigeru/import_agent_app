module PlaceOrders
  class NavbarComponent < ViewComponent::Base
    def initialize(org:, import:, before_orders:, confirm:)
      super()
      @org = org
      @import = import
      @before_orders = before_orders
      @confirm = confirm
    end

    def import_border_color
      case @import
      when :done
        'border-gray-700'
      when :active
        'border-indigo-600'
      end
    end

    def import_text_color
      case @import
      when :done
        'text-gray-700'
      when :active
        'text-indigo-600'
      end
    end

    def before_orders_border_color
      case @before_orders
      when :done
        'border-gray-700'
      when :active
        'border-indigo-600'
      when :pending
        if @org.orders_to_order.before_order.count.positive?
          'border-gray-700'
        else
          'border-gray-300'
        end
      end
    end

    def before_orders_text_color
      case @before_orders
      when :done
        'text-gray-700'
      when :active
        'text-indigo-600'
      when :pending
        if @org.orders_to_order.before_order.count.positive?
          'text-gray-700'
        else
          'text-gray-300'
        end
      end
    end

    def import_pointer_events
      'pointer-events-none' if current_page?([@org, :place_orders, :import])
    end

    def before_orders_pointer_events
      'pointer-events-none' if @before_orders == :pending && @org.orders_to_order.before_order.blank?
    end

    def confirm_border_color
      case @confirm
      when :pending
        'border-gray-300'
      when :active
        'border-indigo-600'
      end
    end

    def confirm_text_color
      case @confirm
      when :pending
        'text-gray-300'
      when :active
        'text-indigo-600'
      end
    end
  end
end
