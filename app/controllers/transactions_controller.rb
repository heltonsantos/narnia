class TransactionsController < ApplicationController
  include ClientConcern
  include PaginationConcern

  def index
    render json: Transaction.where(wallet: client.wallet).order(updated_at: :desc).page(page).per(per_page).all
  end
end
