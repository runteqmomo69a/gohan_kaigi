class Shop < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :name, presence: true

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
end
