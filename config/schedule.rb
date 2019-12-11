# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
set :output, "log/cron.log"

every :day, :at => '3:00am' do
  rake 'flinders_timetables:update_json[2020] institution:update_semesters[true]'
end

every :day, :at => '3:30am' do
  rake 'adelaide_timetables:update[2020] institution:update_semesters[true]'
end

every :day, :at => '4:00am' do
  rake 'unisa_timetables_public:update institution:update_semesters[true]'
end
