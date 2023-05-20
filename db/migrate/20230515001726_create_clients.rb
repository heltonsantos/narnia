class CreateClients < ActiveRecord::Migration[6.1]
  def change
    create_table :clients do |t|
      t.string :uuid
      t.string :name

      t.index :uuid, unique: true

      t.timestamps
    end
  end
end
