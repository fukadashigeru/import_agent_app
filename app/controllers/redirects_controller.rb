class RedirectsController < ApplicationController
  # before_action :authorize_resource

  def index
    if logged_in?
      redirect_to [:orgs]
      # if last_org
      #   redirect_to [last_org]
      # else
      #   redirect_to [:orgs]
      # end
    else
      redirect_to login_url
    end
  end

  # private

  # def authorize_resource
  #   authorize! nil
  # end
end
