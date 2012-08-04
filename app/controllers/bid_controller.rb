class BidController < ApplicationController

  def index
    bid = Bid.all(:conditions => "listing_id = #{params[:listing_id]}")
    render json: bid
  end

  def show
    bid = Bid.find(params[:id])
    render json: bid
  end

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