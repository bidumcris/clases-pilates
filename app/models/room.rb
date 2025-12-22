class Room < ApplicationRecord
  enum :room_type, { 
    planta_alta_privadas: 0, 
    circuito: 1, 
    planta_baja_mat_accesorios: 2 
  }

  has_many :pilates_classes, dependent: :destroy

  validates :name, presence: true
  validates :room_type, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }
end
