class ForeignKeyIndexes < ActiveRecord::Migration
  def change
    add_index :rooms, :building_id
    add_index :room_bookings, :room_id
  end
end
