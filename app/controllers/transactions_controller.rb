class TransactionsController < ApplicationController
  def index
    render json: Transaction.all
  end
end
