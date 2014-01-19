class Api::V2::RoomBookingsController < Api::V2::BaseController
  def index
    building = Building.for_institution(params[:inst_code]).find_by code: params[:building_code]

    if building.nil? then raise ActiveRecord::RecordNotFound end

    room = Room.find(:first, :conditions => ["building_id = ? AND code = ? ", building.id, params[:room_code]])

    if room.nil? then raise ActiveRecord::RecordNotFound end

    respond_with padded_response @room_bookings = room.room_bookings
  end
end
