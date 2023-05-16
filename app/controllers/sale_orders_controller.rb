class SaleOrdersController < ApplicationController
  include ErrorHandling
  include ClientConcern
  include OrderConcern

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error
  rescue_from Wallets::EnoughStocksError, with: :enough_stock_error

  before_action :client, only: :create

  def create
    order = SaleOrders::Create.call!(
      client: client,
      stock_kind: create_params['stock_kind'],
      unit_price: create_params['unit_price'],
      quantity: create_params['quantity']
    )

    render json: order, status: :created
  end
end
