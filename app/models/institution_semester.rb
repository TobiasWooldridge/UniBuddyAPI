class InstitutionSemester < BaseModel
  belongs_to :institution

  def attempt_to_populate_name()
    # look for an institution_semester with a similar semester code e.g. 'S1'
    similar_semester = InstitutionSemester.where(:code => code).where("institution_semesters.name IS NOT NULL").first

    if (!similar_semester.nil?)
      name = similar_semester.name
    end
  end
end
