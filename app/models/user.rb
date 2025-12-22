class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :level, { basic: 0, intermediate: 1, advanced: 2, admin: 3 }

  has_many :reservations, dependent: :destroy
  has_many :credits, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :level, presence: true

  def admin?
    level == 'admin'
  end

  def can_reserve_class?(pilates_class)
    return false if pilates_class.nil?
    
    case level
    when 'basic'
      pilates_class.level == 'basic'
    when 'intermediate'
      ['basic', 'intermediate'].include?(pilates_class.level)
    when 'advanced'
      true
    else
      false
    end
  end
end
