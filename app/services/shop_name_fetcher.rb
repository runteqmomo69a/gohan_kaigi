# frozen_string_literal: true

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
    return Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_request_failed")) unless response.success?

    candidate_name = extract_name(response.body)
    return Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_not_found")) if candidate_name.blank?

    Result.new(name: candidate_name, error: nil)
  rescue Faraday::Error
    Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_request_failed"))
  rescue StandardError
    Result.new(name: nil, error: I18n.t("views.shops.form.fetch_name_unexpected_error"))
  end

  private

  def extract_name(body)
    document = Nokogiri::HTML(body)

    og_title = document.at_css('meta[property="og:title"]')&.[]("content")&.strip
    return og_title if og_title.present?

    document.at_css("title")&.text&.strip
  end
end
