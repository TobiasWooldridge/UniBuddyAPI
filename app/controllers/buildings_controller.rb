class BuildingsController < ApplicationController
  respond_to :html, :xml, :json
  def index
    @buildings = Building.all
    respond_with(@entries = Building.all)
  end

  respond_to :html, :xml, :json
  def show
    respond_with(@building = Building.find(params[:id]))
  end
end
