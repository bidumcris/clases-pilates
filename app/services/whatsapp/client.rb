require "net/http"
require "json"

module Whatsapp
  class Client
    GRAPH_VERSION = ENV.fetch("WHATSAPP_GRAPH_API_VERSION", "v20.0")

    def initialize(
      access_token: ENV["WHATSAPP_ACCESS_TOKEN"],
      phone_number_id: ENV["WHATSAPP_PHONE_NUMBER_ID"],
      raise_delivery_errors: ENV.fetch("WHATSAPP_RAISE_DELIVERY_ERRORS", "0") == "1"
    )
      @access_token = access_token
      @phone_number_id = phone_number_id
      @raise_delivery_errors = raise_delivery_errors
    end

    def enabled?
      @access_token.present? && @phone_number_id.present?
    end

    # Envía un template aprobado (Utility/Marketing) por Cloud API.
    #
    # @param to [String] número destino (cualquier formato; se normaliza a E.164 AR)
    # @param template_name [String]
    # @param language [String] ej: "es_AR"
    # @param variables [Array<String>] variables en orden para body ({{1}}, {{2}}, ...)
    def send_template(to:, template_name:, language: "es_AR", variables: [])
      raise "WhatsApp Cloud API no configurado" unless enabled?

      to_e164 = Whatsapp::Phone.normalize_ar(to)
      raise "Número inválido para WhatsApp" if to_e164.blank?

      payload = {
        messaging_product: "whatsapp",
        to: to_e164.delete_prefix("+"),
        type: "template",
        template: {
          name: template_name,
          language: { code: language },
          components: build_components(variables)
        }
      }

      post_json(messages_url, payload)
    rescue => e
      Rails.logger.error("[WhatsApp] send_template error: #{e.class}: #{e.message}")
      raise if @raise_delivery_errors
      nil
    end

    private

    def messages_url
      "https://graph.facebook.com/#{GRAPH_VERSION}/#{@phone_number_id}/messages"
    end

    def build_components(variables)
      vars = Array(variables).map(&:to_s)
      return [] if vars.empty?

      [
        {
          type: "body",
          parameters: vars.map { |value| { type: "text", text: value } }
        }
      ]
    end

    def post_json(url, payload)
      uri = URI.parse(url)
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{@access_token}"
      req["Content-Type"] = "application/json"
      req.body = JSON.dump(payload)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      res = http.request(req)
      if res.code.to_i >= 400
        Rails.logger.error("[WhatsApp] API error #{res.code}: #{res.body}")
        raise "WhatsApp API error #{res.code}"
      end

      JSON.parse(res.body) rescue res.body
    end
  end
end

