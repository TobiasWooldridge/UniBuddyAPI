class Api::V1::TopicsController < Api::V1::BaseController
  def index
    @topics = Topic.group(:subject_area).order(:subject_area).pluck_h(:subject_area)
    respond_with(@topics)
  end

  def subject_area
    @topics = Topic.where(:subject_area => params[:subject_area]).pluck_h(
      :name,
      :subject_area,
      :topic_number,
      :year,
      :semester
    )

    respond_with(@topics)
  end

  def topic_number
    @topics = Topic

    [:subject_area, :topic_number, :year, :semester].each do |keyword|
      if !params[keyword].nil?
        @topics = @topics.where(keyword => params[keyword])
      end
    end

    respond_with(@topics)
  end

  def classes
    @topics = Topic.where(
      :subject_area => params[:subject_area],
      :topic_number => params[:topic_number],
      :id => params[:topic_id]
    )

    [:year, :semester, :units].each do |keyword|
      if !params[keyword].nil?
        @topics = @topics.where(keyword => params[keyword])
      end
    end
  end
end
