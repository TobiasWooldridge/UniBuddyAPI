class Api::V2::BuildingsController < Api::V2::BaseController
  def index
    @buildings = Building.for_institution(params[:inst_code])

    respond_with padded_response @buildings
  end

  def show
    @building = Building.for_institution(params[:inst_code]).where(:code => params[:building_code]).first

    respond_with padded_response @building
  end
end
