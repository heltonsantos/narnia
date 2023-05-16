Rails.application.routes.draw do
  resources :orders
  resources :transactions
  resources :stocks
  resources :wallets

  resources :clients, param: :uuid do
    resources :purchase_orders, only: %i[create]
  end
end
