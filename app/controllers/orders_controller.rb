class OrdersController < ApplicationController
  include ClientConcern
  include PaginationConcern

  def index
    render json: Order.where(client: client).order(updated_at: :desc).page(page).per(per_page).all
  end
end
