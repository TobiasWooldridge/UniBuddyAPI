class Api::V1::TopicsController < Api::V1::BaseController
  def subject_areas
    @topics = Topic.group(:subject_area).order(:subject_area).pluck_h(:subject_area)
    respond_with(@topics)
  end

  def index
    @topics = Topic

    [:subject_area, :topic_number, :code, :year, :semester].each do |keyword|
      if !params[keyword].nil?
        @topics = @topics.where(keyword => params[keyword])
      end
    end

    respond_with(@topics.pluck_h(:id, :name, :code, :subject_area, :topic_number, :year, :semester))
  end

  def show
    @topic = Topic.find(params[:topic_id])

    respond_with(@topic);
  end

  def classes
    topic = Topic.find(params[:topic_id])

    classes = ClassType.where(:topic => topic).includes(:class_group)

    respond_with(classes);
  end
end
