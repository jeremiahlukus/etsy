Rails.application.routes.draw do

  devise_for :users

  resource :shopping_cart

  resources :listings do
    collection do
      get 'search'
    end
    resources :orders, only: [:new, :create]
  end
  get 'pages/about'
  get 'pages/contact'
  get 'seller' => "listings#seller"
  get 'sales' => "orders#sales"
  get 'purchases' => "orders#purchases"
  root 'listings#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
