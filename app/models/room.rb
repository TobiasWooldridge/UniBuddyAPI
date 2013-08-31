class Room < ActiveRecord::Base
  belongs_to :building
  has_many :room_bookings, :dependent => :destroy

  def next_booking
  	RoomBooking.where(:room_id => id).where('starts_at > ?', Time.now.to_s).order(:starts_at).first	
  end

  def building_code
    building.code
  end

  def free_until_today
  	n = next_booking

    end_of_day = Time.now.at_end_of_day

    (n.nil? or not n.starts_at.today?) ? end_of_day : n.starts_at
  end

  def full_code
    "%s%s" % [building.code, code]
  end

  def full_name
    "%s %s" % [building.name, code]
  end

  def to_s
     "%s (%s)" % [full_name, full_code]
  end

  def as_json(options = {})
    {
      building_code: self.building_code,
      code: self.code,
      name: self.name,
      full_code: self.full_code,
      full_name: self.full_name,
      created_at: self.created_at,
      updated_at: self.updated_at,
      capacity: self.capacity
    }
  end
end