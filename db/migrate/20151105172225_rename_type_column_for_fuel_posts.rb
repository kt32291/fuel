class RenameTypeColumnForFuelPosts < ActiveRecord::Migration
  def change
  	rename_column :fuel_posts, :type, :post_type
  end
end
