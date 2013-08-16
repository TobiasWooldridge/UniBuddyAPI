class TermDates < ActiveRecord::Base


  class << self
    def current_week
      TermDates.where("now() BETWEEN starts_at AND ends_at").first or ""
    end
  end
end
