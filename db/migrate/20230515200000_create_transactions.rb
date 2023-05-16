class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.string :uuid
      t.string :type
      t.integer :nature
      t.decimal :value
      t.string :description

      t.references :wallet, null: false, foreign_key: true

      t.index :uuid, unique: true

      t.timestamps
    end
  end
end
