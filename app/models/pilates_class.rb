class PilatesClass < ApplicationRecord
  belongs_to :room
  belongs_to :instructor
  has_many :reservations, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :users, through: :reservations

  enum :level, { basic: 0, intermediate: 1, advanced: 2 }

  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :max_capacity, presence: true, numericality: { greater_than: 0 }
  validate :end_time_after_start_time

  scope :upcoming, -> { where("start_time >= ?", Time.current).order(start_time: :asc) }
  scope :past, -> { where("start_time < ?", Time.current).order(start_time: :desc) }
  scope :by_room, ->(room_id) { where(room_id: room_id) }

  def available_spots
    max_capacity - reservations.where(status: :confirmed).count
  end

  def full?
    available_spots <= 0
  end

  def availability_percentage
    return 0 if max_capacity.zero?
    (available_spots.to_f / max_capacity * 100).round
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    errors.add(:end_time, 'debe ser después de la hora de inicio') if end_time <= start_time
  end
end
