class Shop < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :name, presence: true
end
