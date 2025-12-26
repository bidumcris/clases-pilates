class Payment < ApplicationRecord
  belongs_to :user

  enum :payment_method, { card: 0, qr: 1, deposit: 2 }
  enum :payment_status, { pending: 0, completed: 1, failed: 2, refunded: 3 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :payment_status, presence: true

  scope :completed, -> { where(payment_status: :completed) }
  scope :pending, -> { where(payment_status: :pending) }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      amount
      created_at
      id
      payment_method
      payment_status
      transaction_id
      updated_at
      user_id
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  def complete!
    update(payment_status: :completed)
  end

  def fail!
    update(payment_status: :failed)
  end
end
