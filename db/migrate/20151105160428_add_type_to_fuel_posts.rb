class AddTypeToFuelPosts < ActiveRecord::Migration
  def change
  	add_column :fuel_posts, :type, :string
  end
end
