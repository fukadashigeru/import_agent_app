Rails.application.routes.draw do
  root 'orders/ordering_org_sides#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :orgs, only: %i[index show]
  namespace :orders do
    resources :ordering_org_sides, only: %i[index]
  end
end
