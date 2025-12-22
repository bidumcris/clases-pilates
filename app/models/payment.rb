class Payment < ApplicationRecord
  belongs_to :user

  enum :payment_method, { card: 0, qr: 1, deposit: 2 }
  enum :payment_status, { pending: 0, completed: 1, failed: 2, refunded: 3 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :payment_status, presence: true

  scope :completed, -> { where(payment_status: :completed) }
  scope :pending, -> { where(payment_status: :pending) }

  def complete!
    update(payment_status: :completed)
  end

  def fail!
    update(payment_status: :failed)
  end
end
