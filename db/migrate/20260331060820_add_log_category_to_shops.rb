# frozen_string_literal: true

class AddLogCategoryToShops < ActiveRecord::Migration[7.1]
  def change
    add_column :shops, :log_category, :string
  end
end
