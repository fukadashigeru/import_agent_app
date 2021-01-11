module Orders
  class BeforeOrdersController < ApplicationController
    before_action :set_org

    def index
      @orders = Order.where(status: :before_order).order(created_at: :desc)
    end

    private

    def set_org
      @org = Org.find(params[:org_id])
    end
  end
end
