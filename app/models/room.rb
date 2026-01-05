class Room < ApplicationRecord
  enum :room_type, {
    planta_alta_privadas: 0,
    circuito: 1,
    planta_baja_mat_accesorios: 2
  }

  has_many :pilates_classes, dependent: :destroy

  scope :private_enabled, -> { where(room_type: :planta_alta_privadas) }

  validates :name, presence: true
  validates :room_type, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      capacity
      created_at
      id
      name
      room_type
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[pilates_classes]
  end
end
