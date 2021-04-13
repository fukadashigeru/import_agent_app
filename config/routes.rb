Rails.application.routes.draw do
  root 'orgs#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # ログイン/セッション
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  # サインアップ/認証
  get '/signup', to: 'user_registerers#new'
  resource :user
  resources :user_registerers, only: %i[new create]
  resources :user_email_changers, only: %i[new create edit update]
  resource :password, only: %i[edit update]
  resources :password_resets, only: %i[new create edit update destroy]

  resources :orgs, only: %i[index show] do
    namespace :orders do
      resources :before_orders, only: %i[index]
      resources :after_orders, only: %i[index]
    end
    namespace :place_orders do
      resource :import, only: %i[show create]
    end
    resources :suppliers, only: %i[index show edit update]
  end
end
