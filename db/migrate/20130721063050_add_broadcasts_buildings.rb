class AddBroadcastsBuildings < ActiveRecord::Migration
  def change
    create_table :broadcasts_buildings, :id => false do |t|
      t.integer :broadcast_id
      t.integer :building_id
    end
  end
end
