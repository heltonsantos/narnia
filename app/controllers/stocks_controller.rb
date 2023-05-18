class StocksController < ApplicationController
  include ClientConcern
  include PaginationConcern

  def index
    render json: Stock.where(wallet: client.wallet).order(updated_at: :desc).page(page).per(per_page).all
  end
end
