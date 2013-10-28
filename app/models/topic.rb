class Topic < BaseModel
  has_many :class_types, :dependent => :destroy

  before_save :update_topic_codes

  def get_unique_topic_code
  	if unique_topic_code.nil?
  		self.unique_topic_code = "%s-%s-%s" % [year, semester, code]
  	end

  	unique_topic_code
  end

  def as_json(options = {})
		{
			name: name,
			subject_area: subject_area,
			topic_number: topic_number,
			year: year,
			semester: semester,
			units: units,
			coordinator: coordinator,
			description: description,
			aims: aims,
			learning_outcomes: learning_outcomes,
			assumed_knowledge: assumed_knowledge,
			assessment: assessment,
			class_contact: class_contact,
			enrolment_opens: enrolment_opens,
			census: census,
			withdraw_no_fail_by: withdraw_no_fail_by,
			created_at: created_at,
			updated_at: updated_at,
			enrolment_closes: enrolment_closes,
			code: code,
			unique_topic_code: unique_topic_code,
			classes: class_types
			}    
  end

  private
    def update_topic_codes
      write_attribute :code, subject_area + topic_number

      # Cache in DB for querying
      write_attribute :unique_topic_code, unique_topic_code
      true
    end
end
