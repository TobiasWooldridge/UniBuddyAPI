#!/bin/sh
# Install all necessary bundles
bundle install


echo "Loading database"
rake db:migrate


echo "Loading seed data"
rake db:seed


echo "Scraping room bookings"
rake bookings:update


echo "Scraping term dates"
rake dates:term


echo "Scraping news feeds"
rake rss:blogs


echo "Scraping uni topic timetables"
echo "Adelaide"
rake adelaide_timetables:update

echo "Flinders"
rake flinders_timetables:update