require 'scraper/unisa_timetables'

namespace :unisa_timetables do
  desc 'Update class timetables from the UniSA website'

  task :update, [:subject_area] => :environment do |t, args|
    include Scraper::UnisaTimetables

    desc 'Update'

    logfile = File.open('log/UnisaScraper.log', 'a')
    @logger = Logger.new(MultiIO.new(STDOUT, logfile))
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end

    args.with_defaults(:subject_area => nil, :year => nil)

    @logger.info 'Scraping timetables using username %s' % Rails.application.secrets.unisa_username

    @agent = Mechanize.new
    @agent.add_auth('https://my.unisa.edu.au',
                    Rails.application.secrets.unisa_username,
                    Rails.application.secrets.password)

    study_periods = get_study_periods()

    study_periods.each do |study_period|
      if ((args.year.nil? and study_period.year < Date.today.year) or (!args.year.nil? and study_period.year != args.year) )
        next
      end

      scrape_study_period study_period, args.subject_area
    end
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
