class PilatesClass < ApplicationRecord
  belongs_to :room
  belongs_to :instructor
  has_many :reservations, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :users, through: :reservations

  enum :level, { inicial: 0, basic: 1, intermediate: 2, advanced: 3 }
  enum :class_type, { grupal: 0, privada: 1 }

  before_validation :set_default_name

  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :max_capacity, presence: true, numericality: { greater_than: 0 }
  validate :end_time_after_start_time
  validate :private_class_rules
  validate :no_room_time_overlap

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

  def set_default_name
    return if name.present?
    return unless start_time && instructor

    type = class_type.present? ? class_type.humanize : "Clase"
    level_str = level.present? ? level.humanize : nil
    date_str = I18n.l(start_time.to_date, format: "%d/%m")
    time_str = start_time.strftime("%H:%M")

    parts = [type]
    parts << level_str if level_str.present?
    parts << "- #{instructor.name}"
    parts << "- #{date_str} #{time_str}"

    self.name = parts.compact.join(" ")
  end

  def end_time_after_start_time
    return unless start_time && end_time

    errors.add(:end_time, "debe ser después de la hora de inicio") if end_time <= start_time
  end

  def private_class_rules
    return unless privada?

    if max_capacity.present? && max_capacity != 1
      errors.add(:max_capacity, "debe ser 1 para clases privadas")
    end

    if room && !Room.private_enabled.where(id: room.id).exists?
      errors.add(:room, "debe ser una sala habilitada para privadas")
    end
  end

  # No permitir dos clases que se solapen en la misma sala
  # Regla: si (start_time < other.end_time) y (end_time > other.start_time) => hay solapamiento
  def no_room_time_overlap
    return unless room_id && start_time && end_time

    overlapping = PilatesClass
      .where(room_id: room_id)
      .where.not(id: id)
      .where("start_time < ? AND end_time > ?", end_time, start_time)
      .exists?

    return unless overlapping

    errors.add(:base, "Ya existe una clase en esa sala y horario")
  end
end
