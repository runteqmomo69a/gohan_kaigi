# frozen_string_literal: true

class CreateShops < ActiveRecord::Migration[7.1]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.string :url
      t.string :address
      t.text :memo
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
