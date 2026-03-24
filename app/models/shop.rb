class Shop < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :name, presence: true

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  # 地図検索用の文字列を作る（店名 + イベント場所）
  def map_query(event_place = nil)
    [name, event_place].compact.join(" ")
  end

  # Google Map埋め込み用URL
  def map_embed_url(event_place = nil)
    "https://www.google.com/maps?q=#{CGI.escape(map_query(event_place))}&output=embed"
  end

  # Google Map外部リンク用URL
  def map_link_url(event_place = nil)
    "https://www.google.com/maps/search/?api=1&query=#{CGI.escape(map_query(event_place))}"
  end
end
