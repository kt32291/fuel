class AddAttachmentAttachmentToFuelPosts < ActiveRecord::Migration

  def self.up
  	add_attachment :fuel_posts, :attachment
  end

  def self.down
    remove_attachment :fuel_posts, :attachment
  end
end
