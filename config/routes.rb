Rails.application.routes.draw do
  devise_for :users

  resources :stores do
    resources :products, only: [:index, :show, :edit, :update, :new, :create, :destroy]
    get 'orders', to: 'orders#store_orders', as: :store_orders
    member do
      get 'orders/new', to: 'stores#new_order'
    end
  end
  
  scope :buyers do
    resources :orders, only: [:index, :create, :update, :destroy]
  end

  resources :orders, only: [:show] do
    member do
      put :accept
      put :dispatch_order
      put :complete
      put :cancel
    end
  end

  root to: "welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check

  post "me" => "registrations#me"
  post "new" => "registrations#create", as: :create_registration
  post "sign_in" => "registrations#sign_in"

  get "listing" => "products#listing"
  get '/products/:id', to: 'products#redirect_to_store_product'

  post "search", to: "search#index"

  get 'dashboard/:id', to: 'stores#store_daily_revenue'
end
