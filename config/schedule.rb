# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
set :output, "log/cron.log"

every :day, :at => '3:00am' do
  rake 'flinders_timetables:update_json[2021,AGES]'; rake 'flinders_timetables:update_json[2021,AMST]'; rake 'flinders_timetables:update_json[2021,ARCH]'; rake 'flinders_timetables:update_json[2021,ARTS]'; rake 'flinders_timetables:update_json[2021,ASST]'; rake 'flinders_timetables:update_json[2021,AUDI]'; rake 'flinders_timetables:update_json[2021,AUST]'; rake 'flinders_timetables:update_json[2021,BIOD]'; rake 'flinders_timetables:update_json[2021,BIOL]'; rake 'flinders_timetables:update_json[2021,BTEC]'; rake 'flinders_timetables:update_json[2021,BUSN]'; rake 'flinders_timetables:update_json[2021,CHEM]'; rake 'flinders_timetables:update_json[2021,CHIN]'; rake 'flinders_timetables:update_json[2021,COMP]'; rake 'flinders_timetables:update_json[2021,COMS]'; rake 'flinders_timetables:update_json[2021,CPES]'; rake 'flinders_timetables:update_json[2021,CREA]'; rake 'flinders_timetables:update_json[2021,CRIM]'; rake 'flinders_timetables:update_json[2021,CTEC]'; rake 'flinders_timetables:update_json[2021,DANC]'; rake 'flinders_timetables:update_json[2021,DISH]'; rake 'flinders_timetables:update_json[2021,DRAM]'; rake 'flinders_timetables:update_json[2021,DRAP]'; rake 'flinders_timetables:update_json[2021,DSGN]'; rake 'flinders_timetables:update_json[2021,DSRS]'; rake 'flinders_timetables:update_json[2021,DVST]'; rake 'flinders_timetables:update_json[2021,EASC]'; rake 'flinders_timetables:update_json[2021,EDUC]'; rake 'flinders_timetables:update_json[2021,ENGL]'; rake 'flinders_timetables:update_json[2021,ENGR]'; rake 'flinders_timetables:update_json[2021,ENVH]'; rake 'flinders_timetables:update_json[2021,ENVS]'; rake 'flinders_timetables:update_json[2021,ESOL]'; rake 'flinders_timetables:update_json[2021,EXSC]'; rake 'flinders_timetables:update_json[2021,FACH]'; rake 'flinders_timetables:update_json[2021,FNST]'; rake 'flinders_timetables:update_json[2021,FREN]'; rake 'flinders_timetables:update_json[2021,FSHN]'; rake 'flinders_timetables:update_json[2021,GEOG]'; rake 'flinders_timetables:update_json[2021,GOVT]'; rake 'flinders_timetables:update_json[2021,HACM]'; rake 'flinders_timetables:update_json[2021,HASS]'; rake 'flinders_timetables:update_json[2021,HIST]'; rake 'flinders_timetables:update_json[2021,HLED]'; rake 'flinders_timetables:update_json[2021,HLPE]'; rake 'flinders_timetables:update_json[2021,HLTH]'; rake 'flinders_timetables:update_json[2021,HSMT]'; rake 'flinders_timetables:update_json[2021,INDG]'; rake 'flinders_timetables:update_json[2021,INDO]'; rake 'flinders_timetables:update_json[2021,INNO]'; rake 'flinders_timetables:update_json[2021,INST]'; rake 'flinders_timetables:update_json[2021,INTR]'; rake 'flinders_timetables:update_json[2021,ITAL]'; rake 'flinders_timetables:update_json[2021,JUSS]'; rake 'flinders_timetables:update_json[2021,LAMS]'; rake 'flinders_timetables:update_json[2021,LANG]'; rake 'flinders_timetables:update_json[2021,LEGL]'; rake 'flinders_timetables:update_json[2021,LING]'; rake 'flinders_timetables:update_json[2021,LLAW]'; rake 'flinders_timetables:update_json[2021,LLIR]'; rake 'flinders_timetables:update_json[2021,MATH]'; rake 'flinders_timetables:update_json[2021,MDSC]'; rake 'flinders_timetables:update_json[2021,MGRE]'; rake 'flinders_timetables:update_json[2021,MHSC]'; rake 'flinders_timetables:update_json[2021,MIDW]'; rake 'flinders_timetables:update_json[2021,MMED]'; rake 'flinders_timetables:update_json[2021,NANO]'; rake 'flinders_timetables:update_json[2021,NILS]'; rake 'flinders_timetables:update_json[2021,NMCY]'; rake 'flinders_timetables:update_json[2021,NURS]'; rake 'flinders_timetables:update_json[2021,NUTD]'; rake 'flinders_timetables:update_json[2021,OCCT]'; rake 'flinders_timetables:update_json[2021,OPTO]'; rake 'flinders_timetables:update_json[2021,PALL]'; rake 'flinders_timetables:update_json[2021,PARA]'; rake 'flinders_timetables:update_json[2021,PHCA]'; rake 'flinders_timetables:update_json[2021,PHIL]'; rake 'flinders_timetables:update_json[2021,PHYS]'; rake 'flinders_timetables:update_json[2021,PHYT]'; rake 'flinders_timetables:update_json[2021,POAD]'; rake 'flinders_timetables:update_json[2021,POLI]'; rake 'flinders_timetables:update_json[2021,PSYC]'; rake 'flinders_timetables:update_json[2021,REHB]'; rake 'flinders_timetables:update_json[2021,REMH]'; rake 'flinders_timetables:update_json[2021,SCME]'; rake 'flinders_timetables:update_json[2021,SERC]'; rake 'flinders_timetables:update_json[2021,SOAD]'; rake 'flinders_timetables:update_json[2021,SOCI]'; rake 'flinders_timetables:update_json[2021,SPAN]'; rake 'flinders_timetables:update_json[2021,SPOC]'; rake 'flinders_timetables:update_json[2021,SPTH]'; rake 'flinders_timetables:update_json[2021,STAT]'; rake 'flinders_timetables:update_json[2021,STEM]'; rake 'flinders_timetables:update_json[2021,STEP]'; rake 'flinders_timetables:update_json[2021,THEO]'; rake 'flinders_timetables:update_json[2021,TOUR]'; rake 'flinders_timetables:update_json[2021,VISA]'; rake 'flinders_timetables:update_json[2021,WMST]'; rake 'flinders_timetables:update_json[2021,WORK]'; rake 'flinders_timetables:update_json[2021,XOTH]'; rake 'institution:update_semesters[true]'
end

every :day, :at => '3:30am' do
  rake 'adelaide_timetables:update[2021] institution:update_semesters[true]'
end

every :day, :at => '4:00am' do
  rake 'unisa_timetables_public:update institution:update_semesters[true]'
end

