class Event < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :event_date, presence: true
  validates :unique_url, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :note, length: { maximum: 1000 }, allow_blank: true
  

  before_validation :set_unique_url, on: :create

  private

  def set_unique_url
    self.unique_url ||= SecureRandom.urlsafe_base64(10)
  end
end