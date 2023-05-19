class OrderBooksController < ApplicationController
  include PaginationConcern

  def index
    render json: { buy_orders: buy_orders, sale_orders: sale_orders }
  end

  private

  def buy_orders
    BuyOrder.order(unit_price: :desc).page(page).per(per_page).group(:unit_price, :status).count.transform_keys { |k| k.join('.') }
  end

  def sale_orders
    SaleOrder.order(unit_price: :asc).page(page).per(per_page).group(:unit_price, :status).count.transform_keys { |k| k.join('.') }
  end
end
