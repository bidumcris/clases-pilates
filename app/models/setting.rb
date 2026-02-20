# Configuración global de la empresa (key-value).
# Ej.: accion_minprevturno = minutos mínimos antes del inicio de la clase para permitir reservar.
class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  class << self
    def get(key)
      find_by(key: key)&.value
    end

    def set(key, value)
      value = value.to_s
      record = find_or_initialize_by(key: key)
      record.value = value
      record.save!
      value
    end
  end
end
