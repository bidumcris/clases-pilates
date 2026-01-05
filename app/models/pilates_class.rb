class PilatesClass < ApplicationRecord
  belongs_to :room
  belongs_to :instructor
  has_many :reservations, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :users, through: :reservations

  enum :level, { inicial: 0, basic: 1, intermediate: 2, advanced: 3 }
  enum :class_type, { grupal: 0, privada: 1 }

  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :max_capacity, presence: true, numericality: { greater_than: 0 }
  validate :end_time_after_start_time

  scope :upcoming, -> { where("start_time >= ?", Time.current).order(start_time: :asc) }
  scope :past, -> { where("start_time < ?", Time.current).order(start_time: :desc) }
  scope :by_room, ->(room_id) { where(room_id: room_id) }
  scope :for_user, ->(user) {
    # Filtrar por nivel del usuario y tipo de clase
    classes = where(level: user.allowed_levels)

    if user.privada?
      classes.where(class_type: :privada).joins(:room).merge(Room.private_enabled)
    else
      classes.where(class_type: :grupal)
    end
  }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  # Keep this list conservative: only what we actually filter/search in /admin.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      created_at
      end_time
      id
      instructor_id
      level
      max_capacity
      name
      room_id
      start_time
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[instructor reservations requests room users]
  end

  def available_spots
    max_capacity - reservations.where(status: :confirmed).count
  end

  def full?
    available_spots <= 0
  end

  def availability_percentage
    return 0 if max_capacity.zero?
    (available_spots.to_f / max_capacity * 100).round
  end

  # Verificar si es un día feriado (esto se puede expandir con un modelo Holiday)
  def holiday?
    # Por ahora retornamos false, pero se puede integrar con un modelo de feriados
    false
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    errors.add(:end_time, "debe ser después de la hora de inicio") if end_time <= start_time
  end
end
