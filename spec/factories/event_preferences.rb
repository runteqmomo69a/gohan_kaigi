FactoryBot.define do
  factory :event_preference do
    association :event
    association :user
    dislike_foods { "none" }
    budget { 3 }
    content { "preference note" }
  end
end
