module Orders
  class AfterOrdersController < ApplicationController
    before_action :set_org

    def index
      @orders = @org.orders_to_order.where(status: %i[ordered buying]).order(created_at: :desc)
    end

    private

    def set_org
      @org = Org.find(params[:org_id])
    end
  end
end
