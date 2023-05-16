class PurchaseOrdersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error
  rescue_from Wallets::EnoughBalanceError, with: :enough_balance_error

  before_action :client, only: :create

  def create
    order = PurchaseOrders::Create.call!(
      client: client,
      stock_kind: create_params['stock_kind'],
      unit_price: create_params['unit_price'],
      quantity: create_params['quantity']
    )

    render json: order, status: :created
  end

  private

  def client
    @client ||= Client.find_by!(uuid: create_params['client_uuid'])
  end

  def create_params
    params.permit(:client_uuid, :stock_kind, :unit_price, :quantity)
  end

  def record_not_found_error(exception)
    render json: { error: exception.message }.to_json, status: :not_found
  end

  def enough_balance_error(exception)
    render json: { error: exception.message }.to_json, status: :unprocessable_entity
  end
end
