class TermDates < ActiveRecord::Base
  class << self
    def current_week
      TermDates.where("? BETWEEN starts_at AND ends_at", Time.now).first or ""
    end

    def this_year
      for_year Date.today.at_beginning_of_year
    end

    def for_year year
      TermDates.where("starts_at BETWEEN ? AND ?", year.at_beginning_of_year, year.at_end_of_year) or ""
    end
  end
end
