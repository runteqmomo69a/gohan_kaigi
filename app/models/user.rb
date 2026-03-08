class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 255 }
  
  has_many :events, dependent: :destroy

  has_many :event_participants, dependent: :destroy
  has_many :participating_events, through: :event_participants, source: :event
end
