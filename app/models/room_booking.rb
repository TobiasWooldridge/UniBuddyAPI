class RoomBooking < ActiveRecord::Base
  attr_accessible :cancelled, :booked_for, :type, :description, :ends_at, :room, :starts_at

  belongs_to :room
end
