class Topic < BaseModel
  has_many :class_types, :dependent => :destroy
  has_many :synced_selections, :dependent => :destroy

  belongs_to :institution

  before_create :update_topic_codes
  before_save :update_topic_codes


  def as_json(options = {})
		{
			id: id,
			name: name,
			subject_area: subject_area,
			topic_number: topic_number,
			year: year,
			semester: semester,
      location: location,
      subscript: subscript,
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
			classes: class_types,
			institution: institution.to_h_light
		}
  end

  private
	def update_topic_codes
	  write_attribute :code, subject_area + topic_number
	end
end
