FactoryBot.define do
  factory :event do
    association :user
    sequence(:title) { |n| "event_#{n}" }
    event_date { Date.current }
    event_time { Time.zone.parse("18:00") }
    place { "tokyo" }
    note { "event note" }
    unique_url { nil }
  end
end
