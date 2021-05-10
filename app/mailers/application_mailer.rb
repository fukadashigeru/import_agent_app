class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('APP_DEFAILT_MAIL_FROM', Settings.default_mail_from)
  layout 'mailer'
end
