class Api::V1::BuildingsController < Api::V1::BaseController
  def index
    @buildings = Building.all
    respond_with(@buildings)
  end

  def show
    @building = Building.find_by code: params[:building_code]
    respond_with(@building)
  end
end
