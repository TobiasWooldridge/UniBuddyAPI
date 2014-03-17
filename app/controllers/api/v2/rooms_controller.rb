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

    # Crummy validation. TODO(TobiasWooldridge): Fix this.
    if not Float(params[:longitude]) or not Float(params[:latitude])
      raise "Invalid longitude/latitude"
    end

    suggestion.save

    render json: (padded_response suggestion)
  end
end
