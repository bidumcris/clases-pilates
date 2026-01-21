class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { alumno: 0, instructor: 1, admin: 2 }
  # Nivel SOLO para alumnos (el rol admin vive en `role`)
  enum :level, { inicial: 0, basic: 1, intermediate: 2, advanced: 3 }
  enum :class_type, { grupal: 0, privada: 1 }

  has_many :reservations, dependent: :destroy
  has_many :credits, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :fixed_slots, dependent: :destroy
  has_one :instructor_profile, class_name: "Instructor", dependent: :nullify

  validates :role, presence: true
  validates :level, presence: true
  validates :class_type, presence: true
  validates :dni, uniqueness: true, allow_blank: true

  validates :payment_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :debt_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Valores por defecto
  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.role ||= :alumno
    self.level ||= :inicial
    self.class_type ||= :grupal
  end

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  # Keep this list conservative: avoid encrypted_password/reset tokens, etc.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      active
      additional_info
      birth_date
      class_type
      created_at
      debt_amount
      dni
      email
      fake_email
      id
      join_date
      last_payment_date
      level
      monthly_turns
      mobile
      name
      normal_view
      param1
      param2
      param3
      payment_amount
      payments_count
      phone
      role
      subscription_end
      subscription_start
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[credits payments requests reservations]
  end

  def admin?
    role == "admin"
  end

  def instructor?
    role == "instructor"
  end

  def can_reserve_class?(pilates_class)
    return false if pilates_class.nil?

    # Verificar nivel (por ahora, estrictamente el mismo nivel)
    return false unless pilates_class.level == level

    # Verificar tipo de clase
    if privada?
      pilates_class.privada?
    else
      pilates_class.grupal?
    end
  end

  # Niveles permitidos según el nivel del usuario
  def allowed_levels
    # Por ahora, estrictamente el mismo nivel
    [ level ]
  end

  # --- Helpers para panel de alumnos ---
  def credits_available
    credits.available.sum(:amount)
  end

  def fixed_days_summary
    fixed_slots.active.order(:day_of_week, :hour).map(&:full_description).join(" · ")
  end

  def current_month_reservations_scope
    start_date = Date.current.beginning_of_month
    end_date = Date.current.end_of_month
    reservations.joins(:pilates_class)
                .where(status: :confirmed)
                .where(pilates_classes: { start_time: start_date.beginning_of_day..end_date.end_of_day })
  end

  def turnos_consumidos_mes_actual
    current_month_reservations_scope.where(attendance_status: :presente).count
  end

  def turnos_del_mes
    monthly_turns
  end

  def turnos_adeudados_mes_actual
    return nil unless monthly_turns.present?
    [monthly_turns - turnos_consumidos_mes_actual, 0].max
  end
end
