require 'rubygems'
require 'uri'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'

class WepayController < ApplicationController

  def new
    wepay = WePay.new('97711', '16f8003b49')

    redirect_uri = "http://#{request.host_with_port}/listing/#{params[:listing_id]}/wepay/new"

    if params[:code].nil?
      url = wepay.oauth2_authorize_url(redirect_uri)
      redirect_to(url)
    else
      response = wepay.oauth2_token(params[:code], redirect_uri)
      access_token = response['access_token']

      current_user.access_token = access_token
      current_user.save

      response = wepay.call(
        '/account/create',
        access_token,
        {
          :name => "MinuteToWinIt.Me Account #{:listing_id}",
          "description" => "Located this listing at http://#{request.host_with_port}/listing/#{:listing_id}"
        }
      )

      listing = Listing.find(params[:listing_id])
      listing.account_id = response['account_id']
      listing.save

      redirect_to '/last_listing'
    end
  end
end

=begin
helps you make API calls to the WePay API v2
=end

class WePay
  
  STAGE_API_ENDPOINT = "https://stage.wepayapi.com/v2"
  STAGE_UI_ENDPOINT = "https://stage.wepay.com/v2"
  
  PRODUCTION_API_ENDPOINT = "https://wepayapi.com/v2"
  PRODUCTION_UI_ENDPOINT = "https://www.wepay.com/v2"
    
  # initializes the API application, api_endpoint should be something like 'https://stage.wepay.com/v2'
  def initialize(_client_id, _client_secret, _use_stage = true, _use_ssl = true)
    @client_id = _client_id
    @client_secret = _client_secret
    if _use_stage
      @api_endpoint = STAGE_API_ENDPOINT
      @ui_endpoint = STAGE_UI_ENDPOINT
    else
      @api_endpoint = PRODUCTION_API_ENDPOINT
      @ui_endpoint = PRODUCTION_UI_ENDPOINT
    end
    @use_ssl = _use_ssl
  end
  
  # make a call to the WePay API
  def call(call, access_token = false, params = false)
    # get the url
    url = URI.parse(@api_endpoint + call)
    p url
    # construct the call data and access token
    call = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json', 'User-Agent' => 'WePay Ruby SDK'})
    if params
      call.body = params.to_json
    end
    if access_token
      call.add_field('Authorization: Bearer', access_token);
    end
    # create the request object
    request = Net::HTTP.new(url.host, url.port)
    request.use_ssl = @use_ssl
    # make the call
    response = request.start {|http| http.request(call) }
    # returns JSON response as ruby hash
    JSON.parse(response.body)
  end
  
  # this function returns the URL that you send the user to to authorize your API application
  # the redirect_uri must be a full uri (ex https://www.wepay.com)
  def oauth2_authorize_url(redirect_uri, user_email = false, user_name = false, permissions = "manage_accounts,view_balance,collect_payments,refund_payments,view_user")
    url = @ui_endpoint + '/oauth2/authorize?client_id=' + @client_id.to_s + '&redirect_uri=' + redirect_uri + '&scope=' + permissions
    url += user_name ? '&user_name=' + CGI::escape(user_name) : ''
    url += user_email ? '&user_email=' + CGI::escape(user_email) : ''
  end
  
  #this function will make a call to the /v2/oauth2/token endpoint to exchange a code for an access_token
  def oauth2_token(code, redirect_uri)
    call('/oauth2/token', false, {'client_id' => @client_id, 'client_secret' => @client_secret, 'redirect_uri' => redirect_uri, 'code' => code })
  end
end
