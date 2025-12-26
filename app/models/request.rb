class Request < ApplicationRecord
  belongs_to :user
  belongs_to :pilates_class

  enum :request_type, { alert: 0, fixed_slot: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2, fulfilled: 3 }

  validates :request_type, presence: true
  validates :status, presence: true

  scope :pending_approval, -> { where(status: :pending, request_type: :fixed_slot) }
  scope :alerts, -> { where(request_type: :alert) }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      created_at
      id
      pilates_class_id
      request_type
      status
      updated_at
      user_id
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[pilates_class user]
  end

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
