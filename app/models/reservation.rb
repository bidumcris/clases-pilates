class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :pilates_class

  enum :status, { pending: 0, confirmed: 1, cancelled: 2, completed: 3 }
  enum :attendance_status, { sin_marcar: 0, presente: 1, ausente: 2 }

  validates :reserved_at, presence: true
  validate :user_can_reserve_class
  validate :class_has_availability
  validate :class_not_in_past
  validate :class_not_holiday

  scope :upcoming, -> { joins(:pilates_class).where("pilates_classes.start_time > ?", Time.current) }
  scope :by_month, ->(date) {
    joins(:pilates_class)
      .where("EXTRACT(MONTH FROM pilates_classes.start_time) = ? AND EXTRACT(YEAR FROM pilates_classes.start_time) = ?",
             date.month, date.year)
  }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      attendance_status
      created_at
      id
      pilates_class_id
      reserved_at
      status
      updated_at
      user_id
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[pilates_class user]
  end

  private

  def user_can_reserve_class
    return unless user && pilates_class

    unless user.can_reserve_class?(pilates_class)
      errors.add(:base, "No tienes el nivel necesario para reservar esta clase")
    end
  end

  def class_has_availability
    return unless pilates_class

    if pilates_class.full?
      errors.add(:base, "La clase está completa")
    end
  end

  def class_not_in_past
    return unless pilates_class

    if pilates_class.start_time < Time.current
      errors.add(:base, "No se pueden reservar clases pasadas")
    end
  end

  def class_not_holiday
    return unless pilates_class
    return unless pilates_class.respond_to?(:holiday?) && pilates_class.holiday?

    errors.add(:base, "La clase fue marcada como feriado y no admite reservas")
  end
end
