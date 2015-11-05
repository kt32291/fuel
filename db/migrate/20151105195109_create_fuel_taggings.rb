class CreateFuelTaggings < ActiveRecord::Migration
  def change
    create_table :fuel_taggings do |t|
      t.belongs_to :fuel_post, index: true, foreign_key: true
      t.belongs_to :fuel_tag, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
