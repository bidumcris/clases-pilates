class Payment < ApplicationRecord
  belongs_to :user

  enum :payment_method, { efectivo: 0, debito: 1, credito: 2, transferencia: 3, mercado_pago: 4 }
  enum :payment_status, { pending: 0, completed: 1, failed: 2, refunded: 3 }
  enum :kind, { manual: 0, subscription_fee: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :payment_status, presence: true

  scope :completed, -> { where(payment_status: :completed) }
  scope :pending, -> { where(payment_status: :pending) }
  scope :subscription_fees, -> { where(kind: :subscription_fee) }
  scope :for_period, ->(from, to) { where(period_start: from, period_end: to) }
  scope :due_soon, ->(days: 1) { where(payment_status: :pending, due_date: Date.current + days.days) }
  scope :overdue, -> { where(payment_status: :pending).where("due_date < ?", Date.current) }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      amount
      created_at
      id
      checkout_url
      due_date
      kind
      notes
      paid_at
      payment_method
      payment_status
      period_end
      period_start
      provider
      provider_reference
      turns_included
      transaction_id
      updated_at
      user_id
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  def complete!
    update(payment_status: :completed, paid_at: Time.current)
  end

  def fail!
    update(payment_status: :failed)
  end
end
