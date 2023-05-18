class BuyOrdersController < ApplicationController
  include ErrorHandling
  include ClientConcern
  include OrderConcern

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_error
  rescue_from Wallets::EnoughBalanceError, with: :enough_balance_error

  before_action :client, only: :create

  def create
    order = BuyOrders::Create.call!(
      client: client,
      stock_kind: create_params['stock_kind'],
      unit_price: create_params['unit_price'],
      quantity: create_params['quantity']
    )

    render json: order, status: :created
  end
end
