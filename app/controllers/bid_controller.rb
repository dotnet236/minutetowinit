class BidController < ApplicationController

  def new 
  end

  def create
    model = params[:bid]
    bid = Bid.new(model)
    bid.user = current_user


    #Push bid up to pusher service
    if bid.save
      render json: bid
    else
      throw 'Failed to create bid'
    end
  end
end
