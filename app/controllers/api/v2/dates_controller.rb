class Api::V2::DatesController < Api::V2::BaseController
  def index
    @dates = TermDates.for_institution(params[:inst_code]).this_year

    respond_with padded_response @dates
  end

  def current
    respond_with padded_response TermDates.for_institution(params[:inst_code]).current_week
  end
end
