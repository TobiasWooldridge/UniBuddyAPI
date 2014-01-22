require 'scraper/adelaide_timetables'

namespace :adelaide_timetables do

  desc "Update class timetables from the Adelaide University website"

  task :update => :environment do |t, args|
    include Scraper::AdelaideTimetables
    
    desc "Update"

    year = Date.today.strftime("%Y")
    logfile = File.open("log/AdelaideScraper.log", "a")
    @logger = Logger.new MultiIO.new(STDOUT, logfile)

    @logger.info "Scraping timetables for %s" % year
    @agent = Mechanize.new

    scrape_timetables_from_url "https://cp.adelaide.edu.au/courses/search.asp"
    # Fix topics locations from being blank (by getting room from note below it)
    # For some reason nogokiri does not grab the note tr...
    # page = @agent.get("https://access.adelaide.edu.au/courses/details.asp?year=2014&course=107194+1+3410+1")
    # process_timetable page/"div[id=\"hidedata04_1\"] >table:first", "faketopic"
  end

  private
  agent = nil

  class MultiIO
    def initialize(*targets)
      @targets = targets
    end

    def write(*args)
      @targets.each { |t| t.write(*args) }
    end

    def close
      @targets.each(&:close)
    end
  end

end
