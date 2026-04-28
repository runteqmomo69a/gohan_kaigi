FactoryBot.define do
  factory :like do
    association :shop
    association :user
  end
end
