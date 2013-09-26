class Api::V1::TopicsController < Api::V1::BaseController
  def index
    @topics = Topic.all
    respond_with(@topics)
  end
end
