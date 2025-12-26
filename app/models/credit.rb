class Credit < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expires_at, presence: true
  validate :expires_at_in_future

  scope :available, -> { where(used: false).where('expires_at >= ?', Date.current) }
  scope :used, -> { where(used: true) }
  scope :expired, -> { where('expires_at < ?', Date.current) }
  scope :by_expiration_month, ->(date) { 
    where('EXTRACT(MONTH FROM expires_at) = ? AND EXTRACT(YEAR FROM expires_at) = ?', 
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

  def use!
    update(used: true) unless used?
  end

  private

  def expires_at_in_future
    return unless expires_at

    errors.add(:expires_at, 'debe ser una fecha futura') if expires_at < Date.current
  end
end
