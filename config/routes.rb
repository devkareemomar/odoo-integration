Rails.application.routes.draw do
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  namespace:api do
    resources :odoo

    get '/*a', to: 'application#not_found'
  end


  root "home#index"
end
