class RoomBooking < ActiveRecord::Base
  belongs_to :room

  def duration
  	return ends_at - starts_at
  end

  def as_json(options = {})
    {
      id: id,
      starts_at: self.starts_at,
      ends_at: self.ends_at,
      description: self.description,
      cancelled: self.cancelled,
      room_code: self.room.code,
      booked_for: self.booked_for,
      created_at: self.created_at,
      updated_at: self.updated_at
    }
  end
end
