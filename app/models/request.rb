class Request < ApplicationRecord
  belongs_to :user
  belongs_to :pilates_class

  enum :request_type, { alert: 0, fixed_slot: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2, fulfilled: 3 }

  validates :request_type, presence: true
  validates :status, presence: true

  scope :pending_approval, -> { where(status: :pending, request_type: :fixed_slot) }
  scope :alerts, -> { where(request_type: :alert) }

  def approve!
    update(status: :approved)
  end

  def reject!
    update(status: :rejected)
  end

  def fulfill!
    update(status: :fulfilled)
  end
end
