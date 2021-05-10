module Orders
  class BeforeOrdersController < ApplicationController
    before_action :logged_in_user
    before_action :set_org

    def index
      @orders_repository = Order::OrdersRepository.new(
        org: @org,
        status: [:before_order],
        order_by: :desc
      )
      @orders = @orders_repository.orders.page(params[:page]).per(30)
      @indexed_all_supplier_urls_is_same_by_supplier =
        Supplier::SuppliersRepository.new(org: @org).indexed_all_supplier_urls_is_same_by_supplier
    end

    private

    def set_org
      @org = Org.find(params[:org_id])
    end
  end
end
