FactoryBot.define do
  factory :event_participant do
    association :event
    association :user
  end
end
