class SuppliersController < ApplicationController
  before_action :set_org

  def index
  end

  def edit
    binding.pry
    @form = Supplier::Form.new(org: @org, shop_type: 3)
  end

  def update
  end

  private

  def set_org
    @org = Org.find(params[:org_id])
  end
end
