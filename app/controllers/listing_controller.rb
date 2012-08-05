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
    last_listing = Listing.find(:last)

    if last_listing != nil
      last_completed_at = last_listing.completed_at
      completed_at = last_completed_at.advance(:minutes => 2)
    end

    if last_listing == nil || last_completed_at < Time.now.advance(:minutes => 1)
      completed_at = Time.now.advance(:minutes => 2)
    end

    listing.completed_at = completed_at
    if listing.save
      redirect_to :controller => 'bid', :action => 'new', :listing_id => listing.id
    else
      throw 'Failed to create Listing'
    end
  end

  private
  def get_latest_listing
    Listing.all(:conditions => "completed_at > #{Time.now}").last
  end

end
