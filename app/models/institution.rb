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
      resources: {
        timetable_semesters: semesters_by_year
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

  def semesters_by_year()
    years_h = {}

    InstitutionSemester.where(:institution_id => id).order("sort_order ASC, name ASC").each do |is|
      year = years_h[is.year]

      if (year.nil?)
        year = []

        years_h[is.year] = year
      end

      year.push({ :code => is.code, :name => is.name })
    end

    return years_h
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
