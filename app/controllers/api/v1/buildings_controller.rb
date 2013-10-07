class Api::V1::BuildingsController < Api::V1::BaseController
  def index
    @buildings = Building.all

    respond_with @buildings
    expires_in 1.day, :public => true, 'max-stale' => 0    
  end

  def show
    @building = Building.find_by code: params[:building_code]

    respond_with @building 
    expires_in 1.day, :public => true, 'max-stale' => 0
  end
end
