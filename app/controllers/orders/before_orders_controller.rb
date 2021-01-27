module Orders
  class BeforeOrdersController < ApplicationController
    before_action :set_org

    def index
      @order_repository = Order::OrderRepository.new(
        org: @org,
        shop_type: :ordering_org,
        status: [:before_order],
        order_by: :desc
      )
      @orders = @order_repository.orders.page(params[:page]).per(30)
    end

    private

    def set_org
      @org = Org.find(params[:org_id])
    end
  end
end
