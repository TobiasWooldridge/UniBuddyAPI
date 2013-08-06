class RoomBookingsController < ApplicationController
  respond_to :html, :xml, :json
  def index
    respond_with(@room = Room.find(params[:room_id]))
  end
end
