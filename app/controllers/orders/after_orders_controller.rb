module Orders
  class AfterOrdersController < ApplicationController
    before_action :set_org

    def index
      @orders_repository = Order::OrdersRepository.new(
        org: @org,
        status: %i[ordered buying],
        order_by: :desc
      )
      @orders = @orders_repository.orders.page(params[:page]).per(30)
    end

    private

    def set_org
      @org = Org.find(params[:org_id])
    end
  end
end
