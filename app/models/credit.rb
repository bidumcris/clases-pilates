class Credit < ApplicationRecord
  belongs_to :user

  MONTHLY_AVAILABLE_CAP = 3

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expires_at, presence: true
  validate :expires_at_in_future

  scope :available, -> { where(used: false).where("amount > 0").where("expires_at >= ?", Date.current) }
  scope :available_this_month, -> {
    available.where("EXTRACT(MONTH FROM expires_at) = ? AND EXTRACT(YEAR FROM expires_at) = ?",
                    Date.current.month, Date.current.year)
  }
  scope :used, -> { where(used: true) }
  scope :expired, -> { where("expires_at < ?", Date.current) }
  scope :by_expiration_month, ->(date) {
    where("EXTRACT(MONTH FROM expires_at) = ? AND EXTRACT(YEAR FROM expires_at) = ?",
          date.month, date.year)
  }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      amount
      created_at
      expires_at
      id
      updated_at
      used
      user_id
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  def expired?
    expires_at < Date.current
  end

  # Usar 1 crédito (decrementar amount)
  def use!(amount_to_use = 1)
    new_amount = self.amount - amount_to_use
    if new_amount <= 0
      update(amount: 0, used: true)
    else
      update(amount: new_amount)
    end
  end

  # Helper para crear créditos mensuales
  # @param user [User] Usuario al que se le asignan los créditos
  # @param amount [Integer] Cantidad de créditos
  # @param month [Date] Mes para el cual se crean los créditos (por defecto mes actual)
  # @return [Credit] Crédito creado
  def self.create_monthly(user:, amount:, month: Date.current)
    expires_at = month.end_of_month
    create!(
      user: user,
      amount: amount,
      expires_at: expires_at,
      used: false
    )
  end

  # Otorgar recuperos con tope mensual (saldo disponible) por mes de expiración.
  # Devuelve la cantidad efectivamente otorgada (0 si ya alcanzó el tope).
  def self.grant_capped(user:, amount:, expires_at:, cap: MONTHLY_AVAILABLE_CAP)
    amount = amount.to_i
    return 0 if amount <= 0

    current_available =
      user.credits.available.where(expires_at: expires_at).sum(:amount)

    allowed = [amount, cap - current_available].min
    return 0 if allowed <= 0

    create!(user: user, amount: allowed, expires_at: expires_at, used: false)
    allowed
  end

  # Obtener el mes de expiración
  def expiration_month
    expires_at.beginning_of_month
  end

  # Verificar si el crédito vence este mes
  def expires_this_month?
    expires_at.month == Date.current.month && expires_at.year == Date.current.year
  end

  private

  def expires_at_in_future
    return unless expires_at

    errors.add(:expires_at, "debe ser una fecha futura") if expires_at < Date.current
  end
end
