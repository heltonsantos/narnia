class CreateStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :stocks do |t|
      t.string :uuid
      t.string :kind
      t.string :status

      t.references :wallet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
