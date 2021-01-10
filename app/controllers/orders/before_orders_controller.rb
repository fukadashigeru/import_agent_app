module Orders
  class BeforeOrdersController < ApplicationController
    def index
      @orders = Order.order(created_at: :desc)
    end
  end
end
