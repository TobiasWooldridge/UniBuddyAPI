class BookingImprovements < ActiveRecord::Migration
  def up
    add_column RoomBooking, :booked_for, :string
    add_column RoomBooking, :type, :string
  end

  def down
    remove_column RoomBooking, :booked_for
    remove_column RoomBooking, :type
  end
end
