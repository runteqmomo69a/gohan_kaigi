# frozen_string_literal: true

class AddNoteToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :note, :text
  end
end
