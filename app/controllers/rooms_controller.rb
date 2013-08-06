class RoomsController < ApplicationController
  respond_to :html, :xml, :json
  def index
    respond_with(@rooms = Room.all)
  end

  respond_to :html, :xml, :json
  def show
    respond_with(@room = Room.find(params[:id]))
  end
end
