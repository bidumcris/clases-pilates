class StudentMailer < ApplicationMailer
  def birthday(user)
    @user = user
    name = @user.name.presence || @user.email
    mail(to: @user.email, subject: "Feliz cumpleaños, #{name} 🎉")
  end
end

