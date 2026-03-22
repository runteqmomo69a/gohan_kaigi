class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:line]

  validates :name, presence: true, length: { maximum: 255 }
  
  has_many :events, dependent: :destroy
  has_many :event_participants, dependent: :destroy
  has_many :participating_events, through: :event_participants, source: :event
  has_many :shops, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_shops, through: :likes, source: :shop
end