Minutetowinit::Application.routes.draw do
  devise_for :users

  root :to => 'home#index'

  resources :listing

  resources :last_listing, :only => [:index]

  scope "listing/:listing_id" do
    resources :bid, :except => [:delete]
    resources :wepay
  end
end
