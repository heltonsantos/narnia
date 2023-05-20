require 'sidekiq/web'

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  resources :clients, param: :uuid do
    resources :orders, only: %i[index]
    resources :transactions, only: %i[index]
    resources :stocks, only: %i[index]
    resources :buy_orders, only: %i[create]
    resources :sale_orders, only: %i[create]
  end

  resources :order_books, :only => [:index]
end
