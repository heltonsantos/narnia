class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.string :uuid
      t.string :type
      t.string :status
      t.decimal :unit_price
      t.integer :quantity
      t.string :stock_kind
      t.string :error_message
      t.integer :retry_count, default: 0
      t.date :expired_at
      t.datetime :processing_at
      t.datetime :partial_completed_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.datetime :retryed_at

      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
