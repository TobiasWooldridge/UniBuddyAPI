class Api::V1::DatesController < Api::V1::BaseController
  def index
    @dates = TermDates.this_year
    respond_with(@dates)
    expires_in 1.day, :public => true, 'max-stale' => 0
  end
end
