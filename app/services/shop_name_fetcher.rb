class ShopNameFetcher
  Result = Struct.new(:name, :error, keyword_init: true)
  MAX_REDIRECTS = 3

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url.to_s.strip
  end

  def call
    return Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_blank_url")) if @url.blank?

    response = fetch_response(@url)
    log_instagram_response(response) if instagram_url?
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

  def fetch_response(url, redirect_count = 0)
    response = Faraday.get(url)
    return response unless redirect_response?(response)
    return response if redirect_count >= MAX_REDIRECTS

    location = response.headers["location"]
    return response if location.blank?

    next_url = URI.join(url, location).to_s
    fetch_response(next_url, redirect_count + 1)
  end

  def redirect_response?(response)
    response.status.to_i >= 300 && response.status.to_i < 400
  end

  def instagram_url?
    uri = URI.parse(@url)
    uri.host.to_s.downcase.include?("instagram.com")
  rescue URI::InvalidURIError
    false
  end

  def log_instagram_response(response)
    document = Nokogiri::HTML(response.body)
    og_title_selector = 'meta[property="og:title"]'
    og_image_selector = 'meta[property="og:image"]'

    Rails.logger.info(
      "[Instagram ShopNameFetcher] " \
      "url=#{@url} " \
      "final_url=#{response.env.url} " \
      "status=#{response.status} " \
      "location=#{response.headers["location"].inspect} " \
      "title=#{document.at_css("title")&.text&.squish.inspect} " \
      "og_title=#{document.at_css(og_title_selector)&.[]("content")&.squish.inspect} " \
      "og_image=#{document.at_css(og_image_selector)&.[]("content")&.squish.inspect} " \
      "body_head=#{response.body.to_s.first(500).inspect}"
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
