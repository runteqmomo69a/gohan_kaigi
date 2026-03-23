class EventPreference < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :user_id, uniqueness: { scope: :event_id }

  def budget_label
    case budget
    when 1
      "〜999円"
    when 2
      "1000〜1999円"
    when 3
      "2000〜2999円"
    when 4
      "3000〜3999円"
    when 5
      "4000円以上"
    else
      "未入力"
    end
  end
end
