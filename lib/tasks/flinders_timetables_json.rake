require 'scraper/flinders_timetables_json'
require 'action_view'

namespace :flinders_timetables do

  desc 'Update class timtetables from the Flinders website JSON api'

  task :update_json, [:year, :subject_area] => :environment do |t, args|
    include Scraper::FlindersTimetables
    include ActionView::Helpers::DateHelper

    desc 'Update from JSON'

    args.with_defaults(:year => Date.today.strftime("%Y"), :subject_area => nil)

    puts 'Scraping timetables from JSON for %s (subject area: %s)' % [args.year, args.subject_area || 'all subject areas']

    @agent = Mechanize.new
    @found_topics, @updated_topics, @saved_class_types, @saved_class_groups, @saved_class_sessions = [0,0,0,0,0]
    baseURL = "http://www.flinders.edu.au/webapps/stusys/index.cfm"

    t1 = Time.now

    if args.subject_area.length > 0
      scrape_timetables baseURL, args.year, args.subject_area, Rails.application.secrets.flinders_api_secret
    else
      options = @agent.get('https://www.flinders.edu.au/webapps/stusys/index.cfm/common/getTopicSubjects?format=json&tpyear=%s' % args.year)
      if options.code.to_i < 400
        parsedOptions = JSON.parse options.body
        subjects = parsedOptions['OPTIONSLIST']['OPTIONS']
        puts "Found %i subjects" % subjects.length
        subjects.each do |subject|
          scrape_timetables baseURL, args.year, subject['ID'], Rails.application.secrets.flinders_api_secret
        end
      else
        puts "Failed to get subject list"
      end
    end

    t2 = Time.now

    puts "found %i topics, saved or updated %i topics" % [@found_topics, @updated_topics]
    puts "saved %i class types, %i class groups, %i class sessions" % [@saved_class_types, @saved_class_groups, @saved_class_sessions]

    puts "Completed in %s" % distance_of_time_in_words(t1, t2, include_seconds: true)

    if @truncated.length > 0
      puts "The following topics had truncated results"
      puts @truncated
    end
  end

  private
  agent = nil
  found_topics = 0
  updated_topics = 0
  saved_class_types = 0
  saved_class_groups = 0
  saved_class_sessions = 0
end
