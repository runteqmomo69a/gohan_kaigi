# frozen_string_literal: true

class AddLogNoteToShops < ActiveRecord::Migration[7.1]
  def change
    add_column :shops, :log_note, :text
  end
end
