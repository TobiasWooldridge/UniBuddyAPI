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

    t1 = Time.now

    found_topis, updated_topics, saved_class_types, saved_class_groups, saved_class_sessions = scrape_timetables "http://cmsdev.flinders.edu.au/mis_apps/stusys/index.cfm", args.year, args.subject_area

    t2 = Time.now
    puts "found %i topics, saved or updated %i topics" % [found_topis, updated_topics]
    puts "saved %i class types, %i class groups, %i class sessions" % [saved_class_types, saved_class_groups, saved_class_sessions]

    puts "Completed in %s" % distance_of_time_in_words(t1, t2, include_seconds: true)
  end

  private
  agent = nil
end
