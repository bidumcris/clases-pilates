class Instructor < ApplicationRecord
  has_many :pilates_classes, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
