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
      class_type
      created_at
      email
      id
      level
      role
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

    # Verificar nivel
    level_ok = case level
    when "inicial"
      pilates_class.level == "inicial"
    when "basic"
      [ "inicial", "basic" ].include?(pilates_class.level)
    when "intermediate"
      [ "inicial", "basic", "intermediate" ].include?(pilates_class.level)
    when "advanced"
      true
    else
      false
    end

    return false unless level_ok

    # Verificar tipo de clase
    if privada?
      pilates_class.privada?
    else
      pilates_class.grupal?
    end
  end

  # Niveles permitidos según el nivel del usuario
  def allowed_levels
    case level
    when "inicial"
      [ "inicial" ]
    when "basic"
      [ "inicial", "basic" ]
    when "intermediate"
      [ "inicial", "basic", "intermediate" ]
    when "advanced"
      [ "inicial", "basic", "intermediate", "advanced" ]
    else
      []
    end
  end
end
