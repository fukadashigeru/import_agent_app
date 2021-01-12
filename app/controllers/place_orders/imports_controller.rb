module PlaceOrders
  class ImportsController < ApplicationController
    before_action :set_org

    def index; end

    private

    def set_org
      @org = Org.find(params[:org_id])
    end
  end
end
