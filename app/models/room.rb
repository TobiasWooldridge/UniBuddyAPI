class Room < ActiveRecord::Base
  belongs_to :building
  has_many :room_bookings, :dependent => :destroy

  def next_booking
  	RoomBooking.where(:room_id => id).where('starts_at > ?', Time.now.to_s).order(:starts_at).first	
  end

  def free_until
  	n = next_booking

    n.nil? ? Date.today.at_end_of_week : n.starts_at
  end

  def full_code
    building.code + " " + code
  end
end