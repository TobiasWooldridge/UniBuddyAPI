class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :code
      t.string :name
      t.integer :capacity
      t.references :building

      t.timestamps
    end
  end
end
