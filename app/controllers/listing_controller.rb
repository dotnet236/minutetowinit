class ListingController < ApplicationController
  before_filter :authenticate_user!

  def index
    @listings = Listing.all
    render json: @listings
  end

  def show
    @listing = Listing.find(params[:id])
    render json: @listing
  end

  def new 
    @listing = Listing.new
  end

  def create
    model = params[:listing]
    listing = Listing.new(model)
    listing.user = current_user
    if listing.save
      render json: listing
    else
      throw 'Failed to create Listing'
    end
  end

end
