class Instructor < ApplicationRecord
  belongs_to :user, optional: true
  has_many :pilates_classes, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      created_at
      email
      id
      name
      phone
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[pilates_classes]
  end

  # true si todas las reservas confirmadas de las clases de hoy tienen asistencia marcada (presente o ausente).
  def today_attendance_complete?
    day = Date.current
    scope = Reservation
      .joins(:pilates_class)
      .where(pilates_classes: { instructor_id: id })
      .where(status: :confirmed)
      .where("DATE(pilates_classes.start_time) = ?", day)
    scope.where(attendance_status: :sin_marcar).exists? ? false : true
  end
end
