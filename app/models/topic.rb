class Topic < ActiveRecord::Base
  def code
    subject_area + topic_number
  end
end
