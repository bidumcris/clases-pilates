require "net/http"

module MercadoPago
  class Client
    API_BASE = "https://api.mercadopago.com".freeze

    def initialize(access_token: ENV["MERCADOPAGO_ACCESS_TOKEN"])
      @access_token = access_token
    end

    def configured?
      @access_token.present?
    end

    def create_preference(external_reference:, title:, quantity: 1, unit_price:, payer_email: nil, notification_url: nil, back_urls: {})
      raise "MERCADOPAGO_ACCESS_TOKEN no configurado" unless configured?

      payload = {
        external_reference: external_reference.to_s,
        items: [
          {
            title: title,
            quantity: quantity,
            currency_id: "ARS",
            unit_price: unit_price.to_f
          }
        ]
      }

      payload[:payer] = { email: payer_email } if payer_email.present?
      payload[:notification_url] = notification_url if notification_url.present?
      payload[:back_urls] = back_urls if back_urls.present?
      payload[:auto_return] = "approved" if back_urls.present?

      post_json("/checkout/preferences", payload)
    end

    def fetch_payment(payment_id)
      raise "MERCADOPAGO_ACCESS_TOKEN no configurado" unless configured?
      get_json("/v1/payments/#{payment_id}")
    end

    private

    def get_json(path)
      uri = URI.join(API_BASE, path)
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{@access_token}"
      req["Content-Type"] = "application/json"

      perform(uri, req)
    end

    def post_json(path, payload)
      uri = URI.join(API_BASE, path)
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{@access_token}"
      req["Content-Type"] = "application/json"
      req.body = payload.to_json

      perform(uri, req)
    end

    def perform(uri, req)
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
      json = JSON.parse(res.body) rescue {}

      unless res.is_a?(Net::HTTPSuccess)
        message = json.is_a?(Hash) ? (json["message"] || json["error"] || res.body) : res.body
        raise "Mercado Pago API error (#{res.code}): #{message}"
      end

      json
    end
  end
end

