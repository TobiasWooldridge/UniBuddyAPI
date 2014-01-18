class Api::V2::RoomsController < Api::V2::BaseController
  def index
    building = Building.for_institution(params[:inst_code]).find_by code: params[:building_code]
    
    respond_with padded_response building.rooms
  end

  def show
    building = Building.for_institution(params[:inst_code]).find_by code: params[:building_code]
    respond_with padded_response @room = Room.find_by("building_id = ? AND code = ? ", building.id, params[:room_code])
  end
end
