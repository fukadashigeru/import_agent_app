class OrgsController < ApplicationController
  before_action :set_org, only: %i[show]

  def index
    @orgs = Org.all
  end

  def show
  end

  private

  def set_org
    @org = Org.find(params[:id])
  end
end

