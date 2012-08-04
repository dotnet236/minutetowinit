class Bid < ActiveRecord::Base
  attr_accessible :user_id, :bid_amount, :height, :listing_id, :width, :x, :y

  belongs_to :user
  belongs_to :listing

end
