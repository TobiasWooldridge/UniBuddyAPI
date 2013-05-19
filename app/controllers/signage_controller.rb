class SignageController < ApplicationController
  layout "signage"
  
  def view 
    @building = Building.where(:code => params[:building]).first

    currentHour = Time.parse("13 May 2013 12pm")
    @currentRoomUsages = RoomBooking.where(:room_id => @building.rooms).where('start <= ? AND end > ?', currentHour, currentHour)

    upcomingHour = currentHour + 1.hour
    @upcomingRoomUsages = RoomBooking.where(:room_id => @building.rooms).where('start <= ? AND end > ?', upcomingHour, upcomingHour)

    @activeRooms = []

    @currentRoomUsages.each do |roomUsage|
      @activeRooms.append(roomUsage.room.id)
    end

    @emptyRooms = Room.where(:building_id => @building).where('id NOT IN (?)', @activeRooms)


  end
end
