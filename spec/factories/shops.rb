FactoryBot.define do
  factory :shop do
    association :event
    user { event.user }
    sequence(:name) { |n| "shop_#{n}" }
    url { "https://example.com/shops/1" }
    address { "tokyo" }
    memo { "shop memo" }
    log_note { "log note" }
    ogp_image_url { "https://example.com/shop.png" }
    place_id { nil }
  end
end
