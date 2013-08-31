class Api::V1::RoomBookingsController < Api::V1::BaseController
  def index

    building = Building.find_by code: params[:building_code]
    room = Room.find(:first, :conditions => ["building_id = ? AND code = ? ", building.id, params[:room_code]])

    respond_with(@room_bookings = room.room_bookings)
  end
end
