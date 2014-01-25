require 'scraper/flinders_timetables'

namespace :flinders_timetables do

  desc "Update class timetables from the Flinders website"

  task :update, [:year, :subject_area] => :environment do |t, args|
    include Scraper::FlindersTimetables

    desc "Update"

    args.with_defaults(:year => Date.today.strftime("%Y"), :subject_area => nil)

    puts "Scraping timetables for %s (subject area: %s)" % [args.year, args.subject_area || "all subject areas"]

    @agent = Mechanize.new

    scrape_timetables_from_url "http://stusyswww.flinders.edu.au/timetable.taf", args.year, args.subject_area
  end

  private
  agent = nil
end
