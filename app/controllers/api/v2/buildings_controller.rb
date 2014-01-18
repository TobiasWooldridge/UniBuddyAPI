class Api::V2::BuildingsController < Api::V2::BaseController
  def index
    @buildings = Building.for_institution(params[:inst_code])

    respond_with @buildings
  end

  def show
    @building = Building.for_institution(params[:inst_code]).find_by (:code => params[:building_code])

    respond_with @building
  end
end
