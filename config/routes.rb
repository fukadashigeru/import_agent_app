Rails.application.routes.draw do
  root 'orders/ordering_org_sides#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resource :orgs, only: %i[index]
  namespace :orders do
    resources :ordering_org_sides, only: %i[index]
  end
end
