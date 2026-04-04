# frozen_string_literal: true

class AddPlaceIdToShops < ActiveRecord::Migration[7.1]
  def change
    add_column :shops, :place_id, :string
  end
end
