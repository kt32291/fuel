class CreateFuelTags < ActiveRecord::Migration
  def change
    create_table :fuel_tags do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :fuel_tags, :name
  end
end
