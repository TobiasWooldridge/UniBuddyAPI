class Api::V1::RoomsController < Api::V1::BaseController
  def index
    building = Building.find_by code: params[:building_code]
    respond_with(building.rooms)
  end

  def show
    building = Building.find_by code: params[:building_code]
    respond_with(@room = Room.find(:first, :conditions => ["building_id = ? AND code = ? ", building.id, params[:room_code]]))
  end
end
