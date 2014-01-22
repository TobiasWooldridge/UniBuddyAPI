class Institution < BaseModel
  has_many :buildings, :dependent => :destroy

  has_many :institution_semesters, :dependent => :destroy

  def as_json(options = {})
    to_h
  end

  def to_h()
    {
      code: code,
      name: name,
      nickname: nickname,
      country: country,
      state: state,
      features: {
          timetables: {
              semesters: institution_semesters.pluck_h(:year, :code, :name)
          }
      }
    }
  end


  def to_h_light
    {
        code: code,
        name: name,
        nickname: nickname
    }
  end

  def semesters_with_timetables()
    Topic.select(:year, :semester)
         .where(:institution_id => id)
         .group(:year, :semester)
         .order("year DESC, semester ASC")
  end


  def populate_semesters()
    semesters = Topic.select(:year, :semester)
        .where(:institution_id => id)
        .group(:year, :semester)
        .order("year DESC, semester ASC")

    semesters.each do |semester|
      is = InstitutionSemester.where(:institution_id => id, :year => semester.year, :code => semester.semester).first_or_create

      if (is.name.nil?)
        is.attempt_to_populate_name
      end

      is.save
    end
  end

  class << self
    def flinders()
      Institution.where(:code => "flinders").first
    end

    def adelaide()
      Institution.where(:code => "adelaide").first
    end
  end
end
