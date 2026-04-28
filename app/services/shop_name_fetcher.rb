class ShopNameFetcher
  Result = Struct.new(:name, :error, keyword_init: true)

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url.to_s.strip
  end

  def call
    return Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_blank_url")) if @url.blank?

    response = Faraday.get(@url)
    log_instagram_response(response.body, response.status) if instagram_url?
    return Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_request_failed")) unless response.success?

    candidate_name = extract_name(response.body)
    return Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_not_found")) if candidate_name.blank?

    Result.new(name: candidate_name, error: nil)
  rescue Faraday::Error => e
    log_instagram_error(e) if instagram_url?
    Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_request_failed"))
  rescue StandardError => e
    log_instagram_error(e) if instagram_url?
    Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_unexpected_error"))
  end

  private

  def extract_name(body)
    document = Nokogiri::HTML(body)

    og_title = document.at_css('meta[property="og:title"]')&.[]("content")&.strip
    return og_title if og_title.present?

    document.at_css("title")&.text&.strip
  end

  def instagram_url?
    uri = URI.parse(@url)
    uri.host.to_s.downcase.include?("instagram.com")
  rescue URI::InvalidURIError
    false
  end

  def log_instagram_response(body, status)
    document = Nokogiri::HTML(body)
    og_title_selector = 'meta[property="og:title"]'
    og_image_selector = 'meta[property="og:image"]'

    Rails.logger.info(
      "[Instagram ShopNameFetcher] " \
      "url=#{@url} " \
      "status=#{status} " \
      "title=#{document.at_css("title")&.text&.squish.inspect} " \
      "og_title=#{document.at_css(og_title_selector)&.[]("content")&.squish.inspect} " \
      "og_image=#{document.at_css(og_image_selector)&.[]("content")&.squish.inspect} " \
      "body_head=#{body.to_s.first(500).inspect}"
    )
  end

  def log_instagram_error(error)
    Rails.logger.info(
      "[Instagram ShopNameFetcher Error] " \
      "url=#{@url} " \
      "error_class=#{error.class} " \
      "message=#{error.message.inspect}"
    )
  end
end
