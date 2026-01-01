class FixedSlot < ApplicationRecord
  belongs_to :user
  belongs_to :room
  belongs_to :instructor

  enum :status, { active: 0, paused: 1, cancelled: 2 }

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :hour, presence: true, inclusion: { in: 0..23 }
  validates :level, presence: true
  validates :user_id, uniqueness: { scope: [ :day_of_week, :hour ], message: "Ya tienes un turno fijo en este día y hora" }

  DAYS = {
    0 => "Domingo",
    1 => "Lunes",
    2 => "Martes",
    3 => "Miércoles",
    4 => "Jueves",
    5 => "Viernes",
    6 => "Sábado"
  }.freeze

  def day_name
    DAYS[day_of_week]
  end

  def time_string
    "#{hour}:00"
  end

  def full_description
    "#{day_name} a las #{time_string} - #{room.name} - #{instructor.name}"
  end

  # Buscar la clase correspondiente para una fecha específica
  def find_class_for_date(date)
    return nil unless date.wday == day_of_week

    PilatesClass.where(
      room: room,
      instructor: instructor,
      level: level,
      class_type: :grupal
    ).where(
      "DATE(start_time) = ? AND EXTRACT(HOUR FROM start_time) = ?",
      date, hour
    ).first
  end

  # Crear reserva automática para una fecha si existe la clase
  def create_reservation_for_date(date)
    pilates_class = find_class_for_date(date)
    return nil unless pilates_class
    return nil if pilates_class.start_time < Time.current
    return nil if user.reservations.exists?(pilates_class: pilates_class, status: :confirmed)

    # Verificar si hay disponibilidad
    return nil if pilates_class.full?

    reservation = user.reservations.create(
      pilates_class: pilates_class,
      status: :confirmed,
      reserved_at: Time.current
    )

    reservation.persisted? ? reservation : nil
  end
end
