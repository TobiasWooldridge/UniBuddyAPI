class Api::RoomBookingsController < ApplicationController
  respond_to :html, :xml, :json
  def index
    if not params[:room_id].nil?
      respond_with(@room_bookings = Room.find(params[:room_id]).room_bookings)
    else
      respond_with(@room_bookings = RoomBooking.all)
    end
  end
end
