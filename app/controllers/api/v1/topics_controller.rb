class Api::V1::TopicsController < Api::V1::BaseController
  def index
    @topics = Topic.all
    respond_with(@topics)
  end

  def subject_area
    @topics = Topic.where(:subject_area => params[:subject_area])
    respond_with(@topics)
  end

  def topic_number
    @topics = Topic.where(:subject_area => params[:subject_area], :topic_number => params[:topic_number])
    respond_with(@topics)
  end
end
