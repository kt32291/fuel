module Fuel
	class Tag < ActiveRecord::Base
    extend FriendlyId
    friendly_id :name, use: [:slugged, :finders]

		has_many :taggings
		has_many :posts, through: :taggings

		validates_uniqueness_of :name
	end
end
