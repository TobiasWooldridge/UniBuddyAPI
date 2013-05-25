class SignageController < ApplicationController
  layout "signage"
  
  def view 
    @building = Building.where(:code => params[:building]).first

    currentHour = Time.parse("13 May 2013 12pm")
    @currentRoomUsages = RoomBooking.where(:room_id => @building.rooms).where('starts_at <= ? AND ends_at > ?', currentHour, currentHour)

    upcomingHour = currentHour + 1.hour
    @upcomingRoomUsages = RoomBooking.where(:room_id => @building.rooms).where('(starts_at <= ?) AND (ends_at > ?)', upcomingHour, upcomingHour)

    @activeRooms = []

    @currentRoomUsages.each do |roomUsage|
      @activeRooms.append(roomUsage.room.id)
    end

    @emptyRooms = Room.where(:building_id => @building).where('id NOT IN (?)', @activeRooms)
  end
end
