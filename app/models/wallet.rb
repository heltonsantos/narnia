class Wallet < ApplicationRecord
  belongs_to :client
  has_many :stocks, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :client_id, :balance, presence: true

  def available_stocks(stock_kind)
    stocks.where(stocks: { kind: stock_kind, status: :available })
  end
end
