class Webhooks::MercadoPagoController < ActionController::Base
  protect_from_forgery with: :null_session

  def receive
    # Mercado Pago puede enviar distintos formatos; soportamos los comunes:
    # - JSON: { action: "payment.updated", data: { id: "123" } }
    # - Query: ?type=payment&data.id=123
    payment_id = extract_payment_id

    unless payment_id.present?
      render json: { ok: true }, status: :ok
      return
    end

    client = MercadoPago::Client.new
    unless client.configured?
      render json: { ok: false, error: "not_configured" }, status: :service_unavailable
      return
    end

    mp_payment = client.fetch_payment(payment_id)

    external_reference = mp_payment["external_reference"].to_s
    payment = Payment.find_by(provider: "mercado_pago", provider_reference: external_reference)

    # Si no encontramos por provider_reference, intentamos por transaction_id (pago MP)
    payment ||= Payment.find_by(payment_method: :mercado_pago, transaction_id: payment_id.to_s)

    unless payment
      render json: { ok: true }, status: :ok
      return
    end

    status = mp_payment["status"].to_s
    payment_type = mp_payment["payment_type_id"].to_s
    method_id = mp_payment["payment_method_id"].to_s

    attrs = {
      provider: "mercado_pago",
      transaction_id: payment_id.to_s,
      provider_payload: mp_payment,
      paid_at: (Time.zone.parse(mp_payment["date_approved"]) rescue nil)
    }

    case status
    when "approved"
      attrs[:payment_status] = :completed
    when "rejected", "cancelled"
      attrs[:payment_status] = :failed
    when "refunded", "charged_back"
      attrs[:payment_status] = :refunded
    else
      attrs[:payment_status] = :pending
    end

    # Mapeo simple (opcional) a nuestros métodos internos para reportes:
    # card/debit_card/credit_card -> credito/debito; account_money/cash -> efectivo; bank_transfer/atm -> transferencia
    if payment.payment_method != "mercado_pago"
      # no tocar si fue manual
    else
      attrs[:payment_method] = map_payment_method(payment_type, method_id)
    end

    payment.update!(attrs.compact)

    render json: { ok: true }, status: :ok
  rescue => e
    Rails.logger.error("[MercadoPagoWebhook] #{e.class}: #{e.message}")
    render json: { ok: false }, status: :ok
  end

  private

  def extract_payment_id
    body = request.body.read.to_s
    request.body.rewind

    if body.present? && request.media_type == "application/json"
      json = JSON.parse(body) rescue {}
      return json.dig("data", "id").to_s if json.is_a?(Hash)
    end

    params.dig(:data, :id).to_s.presence || params["data.id"].to_s.presence
  end

  def map_payment_method(payment_type_id, payment_method_id)
    case payment_type_id
    when "debit_card"
      :debito
    when "credit_card"
      :credito
    when "account_money", "cash"
      :efectivo
    when "bank_transfer", "atm"
      :transferencia
    else
      # fallback: lo dejamos como Mercado Pago para no mentir en reportes
      :mercado_pago
    end
  end
end

