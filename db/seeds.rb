# This file contains all the record creation needed to seed the database with its default values.


# Load Flinders University
flinders = Institution.where({
  :id => 1,
  :code => "flinders"
}).first_or_create!

flinders.name = "Flinders University"
flinders.nickname = "Flinders"
flinders.country = "Australia"
flinders.state = "SA"

flinders.save


# Load Adelaide University
adelaide = Institution.where({
  :id => 2,
  :code => "adelaide"
}).first_or_create!

adelaide.name = "Adelaide University"
adelaide.nickname = "Adelaide"
adelaide.country = "Australia"
adelaide.state = "SA"

adelaide.save