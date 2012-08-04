Minutetowinit::Application.routes.draw do
  devise_for :users

  root :to => 'home#index'

  resources :listing

  scope "listing/:listing_id" do
    resources :bid, :only=> [:new, :create]
  end
end
