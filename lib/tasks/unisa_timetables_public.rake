require 'scraper/unisa_timetables_public'

namespace :unisa_timetables_public do
  desc 'Update class timetables from the UniSA website using publically available data'

  task :update, [:subject_area] => :environment do |t, args|
    include Scraper::UnisaTimetables

    desc 'Update'

    logfile = File.open('log/UnisaScraperPublic.log', 'a')
    @logger = Logger.new(MultiIO.new(STDOUT, logfile))
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{severity}: #{msg}\n"
    end
    @logger.level = Logger::DEBUG

    args.with_defaults(:subject_area => '*')

    @agent = Mechanize.new
    scrape_topics args.subject_area
  end

  private
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
