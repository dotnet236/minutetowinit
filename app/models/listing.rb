class Listing < ActiveRecord::Base
  attr_accessible :completed_at, :latitude, :longitude, :user_id

  belongs_to :user
end
