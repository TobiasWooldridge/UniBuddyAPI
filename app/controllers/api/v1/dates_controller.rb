class Api::V1::DatesController < Api::V1::BaseController
  def index
    @dates = TermDates.all
    respond_with(@dates)
  end
end
