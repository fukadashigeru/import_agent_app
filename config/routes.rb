Rails.application.routes.draw do
  root 'orgs#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :orgs, only: %i[index show] do
    namespace :orders do
      resources :before_orders, only: %i[index]
      resources :after_orders, only: %i[index]
    end
    namespace :place_orders do
      resource :import, only: %i[show create]
    end
    resources :suppliers
  end
end
