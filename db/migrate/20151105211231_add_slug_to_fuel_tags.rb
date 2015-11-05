class AddSlugToFuelTags < ActiveRecord::Migration
  def change
    add_column :fuel_tags, :slug, :string
    add_index :fuel_tags, :slug, unique: true
  end
end
