class Timeline < ApplicationRecord
  ORDER_ACTIONS = %w[
    sale_order_processed
    sale_order_processed_with_partial_stock
    buy_order_processed
    buy_order_requeued
    buy_order_retried
  ].freeze

  STOCK_ACTIONS = %w[
    stock_transferred
  ].freeze

  belongs_to :timelineref, polymorphic: true

  validates :action, :description, presence: true
  validates :action, inclusion: { in: ORDER_ACTIONS + STOCK_ACTIONS }
end
