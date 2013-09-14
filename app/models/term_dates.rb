class TermDates < ActiveRecord::Base
  class << self
    def current_week
      TermDates.where("? BETWEEN starts_at AND ends_at", Time.now).first or ""
    end

    def this_year
      for_year
    end

    def for_year (year = Date.today.at_beginning_of_year)
      TermDates.where("starts_at BETWEEN ? AND ?", year.at_beginning_of_year, year.at_end_of_year) or ""
    end
  end

  def as_json(options = {})
    {
      starts_at: self.starts_at,
      ends_at: self.ends_at,
      semester: self.semester,
      week: self.week,
      created_at: self.created_at,
      updated_at: self.updated_at
    }
  end
end
