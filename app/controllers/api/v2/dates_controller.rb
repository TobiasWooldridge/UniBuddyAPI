class Api::V2::DatesController < Api::V2::BaseController
  def index
    @dates = TermDates.for_institution(params[:inst_code]).this_year

    respond_with padded_response @dates
  end
end
