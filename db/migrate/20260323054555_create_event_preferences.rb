class CreateEventPreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :event_preferences do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :dislike_foods
      t.integer :budget
      t.text :content

      t.timestamps
    end
    add_index :event_preferences, [:event_id, :user_id], unique: true
  end
end
