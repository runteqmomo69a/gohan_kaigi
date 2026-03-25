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

  # Google Map埋め込み用URL（place_idがあれば優先して使用、なければ店名ベースでフォールバック）
  def map_embed_url(event_place = nil)
    if place_id.present?
      "https://www.google.com/maps/embed/v1/place?key=#{ENV['GOOGLE_MAPS_API_KEY']}&q=place_id:#{place_id}"
    else
      "https://www.google.com/maps?q=#{CGI.escape(map_query(event_place))}&output=embed"
    end
  end

  # Google Map外部リンク用URL
  def map_link_url(event_place = nil)
    "https://www.google.com/maps/search/?api=1&query=#{CGI.escape(map_query(event_place))}"
  end

  # Places APIを使ってplace_idを取得する（店名 + イベント場所から検索）
  def fetch_place_id(event_place = nil)
    query = map_query(event_place)

    response = Faraday.post(
      "https://places.googleapis.com/v1/places:searchText"
    ) do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["X-Goog-Api-Key"] = ENV["GOOGLE_MAPS_API_KEY"]
      req.headers["X-Goog-FieldMask"] = "places.id"
      req.body = { textQuery: query }.to_json
    end

    data = JSON.parse(response.body)
    data["places"]&.first&.dig("id")
  end
end
