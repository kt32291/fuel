module Fuel
	class Tag < ActiveRecord::Base
		has_many :taggings
		has_many :posts, through: :taggings

		validates_uniqueness_of :name
	end
end
