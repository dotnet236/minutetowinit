class LastListingController < ApplicationController
  before_filter :authenticate_user!

  def index
    listing = Listing.all(:conditions => ["completed_at > ?", Time.now]).first
    if listing == nil
      listing = Listing.find(:last)
    end
    redirect_to :controller => 'bid', :action => 'new', :listing_id => listing.id
  end

end
