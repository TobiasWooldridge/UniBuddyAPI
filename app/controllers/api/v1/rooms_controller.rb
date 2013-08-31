class Api::V1::RoomsController < Api::V1::BaseController
  def index
    if params[:building_id].nil?
      respond_with(@rooms = Room.all)
    else
      respond_with(@rooms = Building.find(params[:building_id]).rooms)
    end
  end

  def show
    respond_with(@room = Room.find(params[:id]))
  end
end
