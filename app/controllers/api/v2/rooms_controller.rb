class Api::V2::RoomsController < Api::V2::BaseController
  def index
    building = Building.for_institution(params[:inst_code]).find_by code: params[:building_code]
    
    respond_with padded_response building.rooms
  end

  def show
    building = Building.for_institution(params[:inst_code]).find_by code: params[:building_code]
    respond_with padded_response Room.find_by("building_id = ? AND code = ? ", building.id, params[:room_code])
  end

  def suggest_details
    building = Building.for_institution(params[:inst_code]).find_by code: params[:building_code]

    room = Room.find_by("building_id = ? AND code = ? ", building.id, params[:room_code])

    suggestion = RoomDetailsSuggestion.new({
         longitude: params[:longitude],
         latitude: params[:latitude],
         room: room,
         latitude: params[:latitude],
     })

    if params[:longitude] == nil or params[:longitude] == nil
      raise "Invalid longitude/latitude"
    end

    respond_with padded_response suggestion
  end
end
