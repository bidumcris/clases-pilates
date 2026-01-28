class Webhooks::WhatsappController < ActionController::API
  # Meta webhook verification (GET)
  # https://developers.facebook.com/docs/whatsapp/cloud-api/guides/set-up-webhooks
  def verify
    mode = params["hub.mode"]
    token = params["hub.verify_token"]
    challenge = params["hub.challenge"]

    expected = ENV["WHATSAPP_WEBHOOK_VERIFY_TOKEN"].to_s

    if mode == "subscribe" && token.present? && token == expected
      render plain: challenge.to_s, status: :ok
    else
      render plain: "forbidden", status: :forbidden
    end
  end

  # Webhook receive (POST)
  def receive
    # Por ahora solo logueamos el payload para diagnóstico/entregas.
    Rails.logger.info("[WhatsAppWebhook] #{request.raw_post}")
    head :ok
  end
end

