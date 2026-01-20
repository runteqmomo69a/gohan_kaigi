class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.date :event_date, null: false
      t.time :event_time
      t.string :place
      t.string :unique_url, null: false

      t.timestamps
    end

    add_index :events, :unique_url, unique: true
  end
end
