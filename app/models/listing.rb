class Listing < ActiveRecord::Base
  attr_accessible :completed_at, :latitude, :longitude, :user_id, :image, :account_id

  belongs_to :user

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
end
