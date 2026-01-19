class ContactMailer < ApplicationMailer
  STUDIO_EMAIL = "energiapilatesr4@gmail.com".freeze

  def contact_message(name:, email:, whatsapp:, reason:, message:)
    @name = name
    @email = email
    @whatsapp = whatsapp
    @reason = reason
    @message = message

    mail(
      to: STUDIO_EMAIL,
      subject: "Contacto web - #{@name}"
    )
  end
end

