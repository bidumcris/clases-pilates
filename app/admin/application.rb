ActiveAdmin.setup do |config|
  # Configuración global para todos los recursos
end

# Helper para formatear moneda
module ActiveAdmin::ViewHelpers
  def format_currency(amount)
    number_to_currency(amount, unit: "€", separator: ",", delimiter: ".")
  end
end
