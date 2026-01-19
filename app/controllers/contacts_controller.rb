class ContactsController < ApplicationController
  # Página pública: no requiere auth
  protect_from_forgery with: :exception

  def create
    # Honeypot simple anti-spam
    if params[:website].present?
      redirect_to root_path(anchor: "contacto"), notice: "¡Gracias! Te contactamos pronto."
      return
    end

    contact_params = params.permit(:name, :email, :whatsapp, :reason, :message)

    if contact_params[:name].blank? || contact_params[:message].blank?
      redirect_to root_path(anchor: "contacto"), alert: "Por favor completá tu nombre y tu mensaje."
      return
    end

    ContactMailer.contact_message(
      name: contact_params[:name],
      email: contact_params[:email],
      whatsapp: contact_params[:whatsapp],
      reason: contact_params[:reason],
      message: contact_params[:message]
    ).deliver_now

    redirect_to root_path(anchor: "contacto"), notice: "¡Mensaje enviado! Te respondemos a la brevedad."
  rescue StandardError
    redirect_to root_path(anchor: "contacto"), alert: "No pudimos enviar el mensaje en este momento. Probá por WhatsApp."
  end
end

