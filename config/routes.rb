require 'sidekiq/web'

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  resources :orders
  resources :transactions
  resources :stocks
  resources :wallets

  resources :clients, param: :uuid do
    resources :buy_orders, only: %i[create]
    resources :sale_orders, only: %i[create]
  end
end
