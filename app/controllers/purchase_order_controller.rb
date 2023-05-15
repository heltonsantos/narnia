class PurchaseOrdersController < ApplicationController
  before_action :set_order, only: [:show, :update, :destroy]

  def create
    order = PurchaseOrders::Create.call!(create_params)

    render json: order, status: :created
  end

  private

  def create_params
    params.permit(:client_uuid, :stock_kind, :unit_price, :quantity)
  end
end