class Transaction < ApplicationRecord
  belongs_to :wallet

  validates :uuid, :nature, :category, :value, presence: true

  enum nature: { outflow: 0, inflow: 1 }
  enum category: { stock_purchase: 0, stock_sale: 1 }
end
