class Instructor < ApplicationRecord
  belongs_to :user, optional: true
  has_many :pilates_classes, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Ransack (ActiveAdmin) requires explicit allowlists in recent versions.
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      created_at
      email
      id
      name
      phone
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[pilates_classes]
  end
end
