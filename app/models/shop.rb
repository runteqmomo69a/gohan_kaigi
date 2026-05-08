# frozen_string_literal: true

class Shop < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :name, presence: true
  validates :log_note, length: { maximum: 1000, message: :too_long }

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  # 地図検索用の文字列を作る（店名 + イベント場所）
  def map_query(event_place = nil)
    [ name, event_place ].compact.join(" ")
  end

  # Google Map埋め込み用URL（place_idがあれば優先して使用、なければ店名ベースでフォールバック）
  def map_embed_url(event_place = nil)
    if place_id.present?
      "https://www.google.com/maps/embed/v1/place?key=#{ENV.fetch('GOOGLE_MAPS_API_KEY', nil)}&q=place_id:#{place_id}"
    else
      "https://www.google.com/maps?q=#{CGI.escape(map_query(event_place))}&output=embed"
    end
  end

  # Google Map外部リンク用URL
  def map_link_url(event_place = nil)
    "https://www.google.com/maps/search/?api=1&query=#{CGI.escape(map_query(event_place))}"
  end
end
