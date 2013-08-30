class Api::RoomsController < ApplicationController
  respond_to :html, :xml, :json
  def index
    p "---------------"
    p params[:building_id]

    if params[:building_id].nil?
      respond_with(@rooms = Room.all)
    else
      respond_with(@rooms = Building.find(params[:building_id]).rooms)
    end
  end

  respond_to :html, :xml, :json
  def show
    respond_with(@room = Room.find(params[:id]))
  end
end
