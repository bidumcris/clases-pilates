class Credit < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expires_at, presence: true
  validate :expires_at_in_future

  scope :available, -> { where(used: false).where("amount > 0").where("expires_at >= ?", Date.current) }
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
