# frozen_string_literal: true

class EventPreference < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :user_id, uniqueness: { scope: :event_id }

  def budget_label
    case budget
    when 1
      I18n.t("models.event_preference.budget_labels.one")
    when 2
      I18n.t("models.event_preference.budget_labels.two")
    when 3
      I18n.t("models.event_preference.budget_labels.three")
    when 4
      I18n.t("models.event_preference.budget_labels.four")
    when 5
      I18n.t("models.event_preference.budget_labels.five")
    else
      I18n.t("models.event_preference.budget_labels.unset")
    end
  end
end
