class Timeline < ApplicationRecord
  ORDER_ACTIONS = %w[
    sale_order_processed
    buy_order_processed
  ].freeze

  STOCK_ACTIONS = %w[
    stock_transferred
  ].freeze

  belongs_to :timelineref, polymorphic: true

  validates :action, :description, presence: true
  validates :action, inclusion: { in: ORDER_ACTIONS + STOCK_ACTIONS }
end
