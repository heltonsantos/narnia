class BookOrdersController < ApplicationController
  include PaginationConcern

  def index
    render json: query
  end

  private

  def query
    {
      buy_orders: BuyOrder.order(unit_price: :desc).page(page).per(per_page).group(:unit_price).count,
      sale_orders: SaleOrder.order(unit_price: :asc).page(page).per(per_page).group(:unit_price).count
    }
  end
end
