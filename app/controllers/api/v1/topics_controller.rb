class Api::V1::TopicsController < Api::V1::BaseController
  def subject_areas
    @topics = Topic.group(:subject_area).order(:subject_area).pluck_h(:subject_area)

    respond_with @topics
    expires_in 1.day, :public => true, 'max-stale' => 0
  end

  def index
    @topics = Topic

    [:subject_area, :topic_number, :code, :year, :semester].each do |keyword|
      if !params[keyword].nil?
        @topics = @topics.where(keyword => params[keyword])
      end
    end

    respond_with @topics.pluck_h(:name, :code, :unique_topic_code, :subject_area, :topic_number, :year, :semester)
    expires_in 1.day, :public => true, 'max-stale' => 0
  end

  def show
    @topic = Topic.where(:unique_topic_code => params[:unque_topic_code]).includes(:class_types).first

    respond_with(@topic);
  end
end
