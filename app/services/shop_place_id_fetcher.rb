class ShopPlaceIdFetcher
  def self.call(query)
    new(query).call
  end

  def initialize(query)
    @query = query.to_s.strip
  end

  def call
    return if @query.blank?

    response = Faraday.post(
      "https://places.googleapis.com/v1/places:searchText"
    ) do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["X-Goog-Api-Key"] = ENV.fetch("GOOGLE_MAPS_API_KEY", nil)
      req.headers["X-Goog-FieldMask"] = "places.id"
      req.body = { textQuery: @query }.to_json
    end

    data = JSON.parse(response.body)
    data["places"]&.first&.dig("id")
  end
end
