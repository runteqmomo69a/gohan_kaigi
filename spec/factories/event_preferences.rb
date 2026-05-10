FactoryBot.define do
  factory :event_preference do
    association :event
    association :user
    dislike_foods { "none" }
    budget { :three }
    content { "preference note" }
  end
end
