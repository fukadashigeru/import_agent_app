class UserRegistererMailer < ApplicationMailer
  def invitation(user_registerer, token)
    @user_registerer = user_registerer
    @token = token

    mail to: @user_registerer.email, subject: 'ユーザー登録のご案内'
  end
end
