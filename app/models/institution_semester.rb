class InstitutionSemester < BaseModel
  belongs_to :institution

  # This could probably be reimplemented with a more normalised database design, but I don't know how I feel about that
  # complexity for a table with like 12 records
  def self.code_to_name(code)
    is = InstitutionSemester.where(:code => code).where("institution_semesters.name IS NOT NULL").first

    if is.nil?
      return nil
    else
      return is.name
    end
  end
end
