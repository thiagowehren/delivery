Rails.application.routes.draw do
  devise_for :users

  get '/products/:id', to: 'products#redirect_to_store_product'

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

  root to: "welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check
  
  get "listing" => "products#listing"
  post "new" => "registrations#create", as: :create_registration
  post "me" => "registrations#me"
  post "sign_in" => "registrations#sign_in"
end
