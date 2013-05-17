class Room < ActiveRecord::Base
  attr_accessible :building_id, :building, :capacity, :code, :name
end
