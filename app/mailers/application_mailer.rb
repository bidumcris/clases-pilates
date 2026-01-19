class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "energiapilatesr4@gmail.com")
  layout "mailer"
end
