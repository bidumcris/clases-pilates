class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # En Rails 8, si hay schema cache viejo, los enums pueden fallar al boot.
  # Declaramos el tipo explícito para que sea robusto.
  attribute :billing_status, :integer

  enum :role, { alumno: 0, instructor: 1, admin: 2 }
  # Nivel SOLO para alumnos (el rol admin vive en `role`)
  enum :level, { inicial: 0, basic: 1, intermediate: 2, advanced: 3 }
  enum :class_type, { grupal: 0, privada: 1 }
  enum :billing_status, { abonado: 0, pendiente: 1, deudor: 2 }

  # Postgres EXTRACT(DOW): domingo=0 ... sábado=6
  WEEKDAY_OPTIONS = [
    ["Lunes", 1],
    ["Martes", 2],
    ["Miércoles", 3],
    ["Jueves", 4],
    ["Viernes", 5]
  ].freeze

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
  before_validation :sync_whatsapp_opt_in_timestamp

  def set_defaults
    self.role ||= :alumno
    self.level ||= :inicial
    self.class_type ||= :grupal
  end

  def whatsapp_opt_in?
    !!whatsapp_opt_in
  end

  def mobile_e164_ar
    return nil if mobile.blank?
    Whatsapp::Phone.normalize_ar(mobile)
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

  # Ej: "Lunes y Miércoles 18hs · Viernes 10hs"
  def fixed_days_compact_summary
    slots = fixed_slots.active.order(:hour, :day_of_week)
    return "" if slots.empty?

    slots.group_by(&:hour).map do |hour, hour_slots|
      days = hour_slots.map(&:day_name)
      days_str =
        case days.length
        when 0 then ""
        when 1 then days.first
        when 2 then "#{days[0]} y #{days[1]}"
        else
          "#{days[0..-2].join(', ')} y #{days[-1]}"
        end

      "#{days_str} #{hour}hs"
    end.join(" · ")
  end

  def admin?
    role == "admin"
  end

  def instructor?
    role == "instructor"
  end

  private

  def sync_whatsapp_opt_in_timestamp
    return unless respond_to?(:whatsapp_opt_in)

    if whatsapp_opt_in? && whatsapp_opt_in_at.blank?
      self.whatsapp_opt_in_at = Time.current
    end
  end

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  # Keep this list conservative: avoid encrypted_password/reset tokens, etc.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      active
      additional_info
      birth_date
      billing_status
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

  # Niveles permitidos según el nivel del usuario
  def allowed_levels
    # Por ahora, estrictamente el mismo nivel
    [ level ]
  end

  # --- Helpers para panel de alumnos ---
  def credits_available
    credits.available_this_month.sum(:amount)
  end

  def fixed_days_summary
    fixed_slots.active.order(:day_of_week, :hour).map(&:full_description).join(" · ")
  end

  def weekly_days_labels
    return [] if weekly_days.blank?
    map = WEEKDAY_OPTIONS.to_h.invert
    weekly_days.map { |d| map[d.to_i] }.compact
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
