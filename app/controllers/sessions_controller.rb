class SessionsController < ApplicationController
  before_action :set_user, only: %i[create]
  before_action :user_authenticate, only: %i[create]
  # before_action :authorize_resource

  def new
  end

  def create
    log_in @user
    params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
    redirect_back_or root_url
  end

  def destroy
    log_out if logged_in?
    flash[:success] = 'ログアウトしました'
    redirect_to login_url
  end

  private

  def set_user
    @user = User.find_by(email: params[:session][:email].downcase)
  end

  def user_authenticate
    if not @user&.authenticate(params[:session][:password])
      flash.now[:danger] = 'メールアドレスとパスワードの組み合わせが正しくありません。'
      render 'new'
    end
  end

  # def authorize_resource
  #   authorize! nil
  # end
end
