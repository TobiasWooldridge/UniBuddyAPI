class Room < ActiveRecord::Base
  attr_accessible :building_id, :building, :capacity, :code, :name, :room_bookings

  belongs_to :building
  has_many :room_bookings, :dependent => :destroy
end
