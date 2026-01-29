module Whatsapp
  # Normalización mínima para Argentina (móviles).
  module Phone
    # Meta Cloud API requiere número en formato internacional.
    # Normalizamos a E.164 con prefijo +549 (Argentina móvil).
    #
    # Ej:
    # - "3584851541" => +5493584851541
    # - "+54 3584 851541" => +5493584851541
    # - "54 3584851541" => +5493584851541
    def self.normalize_ar(raw)
      digits = raw.to_s.gsub(/\D+/, "")
      return nil if digits.blank?

      digits = digits.sub(/\A00/, "")
      digits = digits.sub(/\A0/, "")

      if digits.start_with?("549")
        "+#{digits}"
      elsif digits.start_with?("54")
        rest = digits.delete_prefix("54")
        "+549#{rest}"
      else
        "+549#{digits}"
      end
    end
  end
end

