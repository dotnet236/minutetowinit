class BidController < ApplicationController

  def new 
    @listing = Listing.find(params[:listing_id])
  end

  def create
    model = params[:bid]
    bid = Bid.new(model)
    bid.user = current_user
    bid.listing_id = params[:listing_id]

    #Push bid up to pusher service
    if bid.save
      render json: bid
    else
      throw 'Failed to create bid'
    end
  end
end
