class CreateTimelines < ActiveRecord::Migration[6.1]
  def change
    create_table :timelines do |t|
      t.string :action
      t.string :description
      t.references :timelineref, polymorphic: true, null: false

      t.timestamps
    end
  end
end
