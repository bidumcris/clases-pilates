class Credit < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expires_at, presence: true
  validate :expires_at_in_future

  scope :available, -> { where(used: false).where('expires_at >= ?', Date.current) }
  scope :expired, -> { where('expires_at < ?', Date.current) }
  scope :by_expiration_month, ->(date) { 
    where('EXTRACT(MONTH FROM expires_at) = ? AND EXTRACT(YEAR FROM expires_at) = ?', 
          date.month, date.year) 
  }

  def expired?
    expires_at < Date.current
  end

  def use!
    update(used: true) unless used?
  end

  private

  def expires_at_in_future
    return unless expires_at

    errors.add(:expires_at, 'debe ser una fecha futura') if expires_at < Date.current
  end
end
