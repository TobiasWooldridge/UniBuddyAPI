class Api::V2::TopicsController < Api::V2::BaseController
  def index
    @topics = Topic.for_institution(params[:inst_code])

    [:subject_area, :topic_number, :code, :year, :semester].each do |keyword|
      if !params[keyword].nil?
        options = params[keyword].split(",")

        @topics = @topics.where(keyword => options.length == 1 ? options.first : options)
      end
    end

    respond_with padded_response @topics.pluck_h(:id, :name, :code, :year, :semester)
  end

  def show
    @topic = Topic.for_institution(params[:inst_code]).where(:id => params[:topic_id]).includes(:class_types).first

    respond_with padded_response @topic
  end
end
