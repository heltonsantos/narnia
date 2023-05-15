Rails.application.routes.draw do
  resources :orders
  resources :transactions
  resources :stocks
  resources :wallets

  resources :clients do
    resources :purchase_orders, only: %i[create]
  end
end
