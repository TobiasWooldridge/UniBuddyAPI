class Topic < BaseModel
  has_many :class_types, :dependent => :destroy

  before_save :update_topic_code

  private
    def update_topic_code
      write_attribute :code, subject_area + topic_number
      true
    end
end
