class Room < ActiveRecord::Base
  belongs_to :building
  has_many :room_bookings, :dependent => :destroy

  def bookings
    room_bookings
  end

  def current_booking
    RoomBooking.where(:room_id => id).where('starts_at < ? AND ends_at > ?', Time.now.to_s, Time.now.to_s).order('starts_at ASC').first 
  end

  def is_empty
    current_booking.nil?
  end

  def next_booking
  	RoomBooking.where(:room_id => id).where('starts_at > ?', Time.now.to_s).order('starts_at ASC').first	
  end

  def todays_bookings
    RoomBooking.where('room_id = ? AND starts_at BETWEEN ? AND ?', id, Time.now.at_beginning_of_day, Time.now.at_end_of_day).order('starts_at ASC')
  end

  def free_until_today
  	n = next_booking

    end_of_day = Time.now.at_end_of_day

    (n.nil? or not n.starts_at.today?) ? end_of_day : n.starts_at
  end

  def full_code
    if code.match(/[0-9]+/) then
      "%s %s" % [building.code, code]
    else
      "%s%s" % [building.code, code]
    end
  end

  def full_name
    "%s %s" % [building.name, code]
  end

  def to_s
     "%s (%s)" % [full_name, full_code]
  end

  def as_json(options = {})
    {
      code: code,
      building_code: building.code,
      name: name,
      full_code: full_code,
      full_name: full_name,
      created_at: created_at,
      updated_at: updated_at,
      capacity: capacity,
      is_empty: is_empty,
      current_booking: current_booking,
      next_booking: next_booking
    }
  end
end