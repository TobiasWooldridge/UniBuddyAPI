class RoomBookingsController < ApplicationController
  # GET /room_bookings
  # GET /room_bookings.json
  def index
    @room = Room.find(params[:room_id])
    raise ActiveRecord::RecordNotFound if @room.nil?
    p room

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @room_bookings }
    end
  end
end
