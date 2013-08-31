class Api::V1::BuildingsController < Api::V1::BaseController
  def index
    @buildings = Building.all
    respond_with(@entries = Building.all)
  end

  def show
    respond_with(@building = Building.find(params[:id]))
  end
end
