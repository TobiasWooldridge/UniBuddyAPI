class Building < ActiveRecord::Base
  has_many :rooms, :dependent => :destroy
  has_and_belongs_to_many :broadcasts

  def bookings_at time
    RoomBooking.where(:room_id => rooms).where('starts_at <= ? AND ends_at > ?', time.to_s, time.to_s)
  end

  def current_bookings
  	bookings_at Time.now
  end

  def upcoming_bookings
  	bookings_at (Time.now + 1.hour)
  end

  def empty_rooms
    # Need to use Building.sanitize because Rails doesn't like you passing parameters to joins. Also, rails hates kittens.
    rooms.joins('LEFT OUTER JOIN room_bookings ON room_bookings.room_id = rooms.id AND ' + Building.sanitize(Time.now) + ' BETWEEN room_bookings
.starts_at AND room_bookings.ends_at')
    .where('room_bookings.id IS NULL')
  end

  def as_json(options = {})
    {
      code: self.code,
      name: self.name,
      created_at: self.created_at,
      updated_at: self.updated_at
    }
  end
end
