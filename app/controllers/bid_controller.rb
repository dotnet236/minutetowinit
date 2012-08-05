require 'pusher'

Pusher.app_id = '25261'
Pusher.key = '81e6ec22b6f7e2bbe1fa'
Pusher.secret = '8b94f16f87a1c8fca5ac'

class BidController < ApplicationController
  before_filter :authenticate_user!

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
      Pusher['bids'].trigger('new-bid', bid)
      render json: bid
    else
      throw 'Failed to create bid'
    end
  end
end
