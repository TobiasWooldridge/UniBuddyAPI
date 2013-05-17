class RoomBooking < ActiveRecord::Base
  attr_accessible :cancelled, :booked_for, :type, :description, :end, :room, :start
end
