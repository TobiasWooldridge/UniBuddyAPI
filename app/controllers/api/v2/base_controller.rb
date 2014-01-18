class Api::V2::BaseController < ActionController::Base
  respond_to :json

  def padded_response data
    return  {
        :data => data
    }
  end
end