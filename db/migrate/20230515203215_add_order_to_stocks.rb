class AddOrderToStocks < ActiveRecord::Migration[6.1]
  def change
    add_reference :stocks, :order, null: true, foreign_key: true
  end
end
