class Api::V1::BaseController < ActionController::Base
  respond_to :xml, :json
end