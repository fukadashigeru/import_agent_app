class UserRegisterersController < ApplicationController
  def new
    @user_registerer = UserRegisterer.new
    authorize! @user_registerer
  end

  def create
    @user_registerer = UserRegisterer.new(user_registerer_params)
    authorize! @user_registerer

    if @user_registerer.save
      @user_registerer.send_invitation_email
      msg  = "入力されたメールアドレスに確認のためのメールを送信しました。\n"
      msg += 'メールに記載されたリンクからユーザー登録へ進んでください。'
      flash[:success] = msg
      redirect_to [:login]
    else
      render 'new'
    end
  end

  private

  def user_registerer_params
    params.require(:user_registerer).permit(:email)
  end
end
