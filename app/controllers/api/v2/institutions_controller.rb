class Api::V2::InstitutionsController < Api::V2::BaseController
  def index
    @institutions = Institution.order("name DESC").all

    respond_with padded_response @institutions
  end

  def show
    @institution = Institution.where(:code => params[:inst_code]).first;

    respond_with padded_response @institution
  end
end