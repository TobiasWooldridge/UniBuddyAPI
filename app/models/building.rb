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
end
