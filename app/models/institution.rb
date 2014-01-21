class Institution < BaseModel
  has_many :buildings, :dependent => :destroy

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
              semesters: semesters_with_timetables.pluck_h(:year, :semester)
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
    Topic.select("topic_year, topic_semester")
         .where(:institution_id => id)
         .group(:year, :semester)
         .order("year DESC, semester ASC")
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
