# frozen_string_literal: true

module ApplicationHelper
  def meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : t("app.title")
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : t("app.description")
  end

  def meta_type
    content_for?(:meta_type) ? content_for(:meta_type) : "website"
  end

  def meta_url
    content_for?(:meta_url) ? content_for(:meta_url) : request.original_url
  end

  def meta_image_url
    image_url(content_for?(:meta_image) ? content_for(:meta_image) : "ogp.png")
  end
end
