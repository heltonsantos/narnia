class CreateStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :stocks do |t|
      t.string :uuid
      t.integer :kind
      t.string :status
      t.datetime :available_at
      t.datetime :on_sale_at

      t.references :wallet, null: false, foreign_key: true

      t.index :uuid, unique: true
      t.index :kind

      t.timestamps
    end
  end
end
