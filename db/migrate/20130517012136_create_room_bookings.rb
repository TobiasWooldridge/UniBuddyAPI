class CreateRoomBookings < ActiveRecord::Migration
  def change
    create_table :room_bookings do |t|
      t.timestamp :start
      t.timestamp :end
      t.text :description
      t.boolean :cancelled
      t.references :room

      t.timestamps
    end
  end
end
