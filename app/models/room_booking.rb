class RoomBooking < ActiveRecord::Base
  belongs_to :room

  def duration
  	return ends_at - starts_at
  end
end
