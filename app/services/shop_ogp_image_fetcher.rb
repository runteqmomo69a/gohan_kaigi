class ShopOgpImageFetcher
  Result = Struct.new(:image_url, :error, keyword_init: true)

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url.to_s.strip
  end

  def call
    return Result.new(image_url: nil, error: I18n.t("services.shop_ogp_image_fetcher.blank_url")) if @url.blank?

    response = Faraday.get(@url)
    return Result.new(image_url: nil, error: I18n.t("services.shop_ogp_image_fetcher.request_failed")) unless response.success?

    image_url = extract_image_url(response.body)
    return Result.new(image_url: nil, error: I18n.t("services.shop_ogp_image_fetcher.not_found")) if image_url.blank?

    Result.new(image_url:, error: nil)
  rescue Faraday::Error
    Result.new(image_url: nil, error: I18n.t("services.shop_ogp_image_fetcher.request_failed"))
  rescue StandardError
    Result.new(image_url: nil, error: I18n.t("services.shop_ogp_image_fetcher.unexpected_error"))
  end

  private

  def extract_image_url(body)
    document = Nokogiri::HTML(body)
    raw_image_url = document.at_css('meta[property="og:image"]')&.[]("content")&.strip
    return if raw_image_url.blank?

    URI.join(@url, raw_image_url).to_s
  rescue URI::InvalidURIError
    nil
  end
end
