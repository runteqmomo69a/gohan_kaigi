# frozen_string_literal: true

class EventPreference < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum :budget, {
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    five: 5
  }, prefix: true

  validates :user_id, uniqueness: { scope: :event_id }

  def budget_label
    I18n.t("models.event_preference.budget_labels.#{budget || 'unset'}")
  end
end
