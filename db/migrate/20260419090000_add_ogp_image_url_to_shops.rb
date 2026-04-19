class AddOgpImageUrlToShops < ActiveRecord::Migration[7.1]
  def change
    add_column :shops, :ogp_image_url, :string
  end
end
