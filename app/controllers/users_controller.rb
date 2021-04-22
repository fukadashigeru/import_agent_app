class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[show edit update destroy]
  before_action :set_user_registerer, only: %i[new create]
  before_action :authenticate, only: %i[new create]
  before_action :check_user_existence, only: %i[new create]
  before_action :check_expiration, only: %i[new create]

  def show
    # authorize! @user
  end

  def new
    @user = User.new
    # authorize! @user
  end

  def create
    @user = User.new(create_user_params)
    # authorize! @user
    @user.email = @user_registerer.email
    @user.agreed_at = Time.zone.now

    if @user.save
      log_in @user
      flash[:success] = 'ユーザー登録が完了しました'
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    authorize! current_user
  end

  def update
    authorize! current_user
    if current_user.update(update_user_params)
      flash[:success] = 'ユーザー情報を変更しました。'
      redirect_to [:user]
    else
      render 'edit'
    end
  end

  def destroy
    authorize! current_user

    if current_user.destroyable?
      current_user.destroy!
      flash[:success] = 'アカウントを削除しました。またのご利用をお待ちしております。'
      redirect_to login_url
    else
      flash[:danger] = <<~MSG
        自身がオーナーとなっている組織が存在するため削除に失敗しました。
        先にオーナーとなっている組織を全て削除してください。
      MSG
      redirect_to [:user]
    end
  end

  private

  def create_user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def update_user_params
    params.require(:user).permit(:name)
  end

  def set_user_registerer
    @user_registerer = UserRegisterer.find(params[:user_registerer_id])

    bad_request unless @user_registerer
  end

  def authenticate
    bad_request unless @user_registerer.authenticated?(params[:token])
  end

  def check_user_existence
    bad_request('すでに登録されているメールアドレスです') if User.exists?(email: @user_registerer.email)
  end

  def check_expiration
    bad_request('リンクの有効期限が切れています') if @user_registerer.expired?
  end

  def bad_request(msg = '不正なリンクです')
    flash[:danger] = msg
    redirect_to [:login]
  end
end
