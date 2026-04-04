# frozen_string_literal: true

class AddUniqueIndexToEventParticipants < ActiveRecord::Migration[7.1]
  def change
    add_index :event_participants, %i[event_id user_id], unique: true
  end
end
