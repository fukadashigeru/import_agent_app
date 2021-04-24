class PasswordResetsController < ApplicationController
  # before_action -> { authorize! nil }
  before_action :set_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'パスワードの再設定について数分以内にメールでご連絡いたします。'
      redirect_to root_url
    else
      flash.now[:danger] = '指定のメールアドレスは見つかりませんでした。'
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = 'パスワードが再設定されました'
      redirect_to root_url
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.find_by(email: params[:email])
  end

  # 有効なユーザーかどうか確認する
  def valid_user
    redirect_to root_url unless @user&.authenticated?(:reset, params[:id])
  end

  # トークンが期限切れかどうか確認する
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = '再設定の有効期限が切れています。'
      redirect_to new_password_reset_url
    end
  end
end
