# This file contains all the record creation needed to seed the database with its default values.


# Load Flinders University
flinders = Institution.where({
            :id => 1,
            :code => 'flinders'
          }).first_or_create!

flinders.name = 'Flinders University'
flinders.nickname = 'Flinders'
flinders.country = 'Australia'
flinders.state = 'SA'

flinders.save


# Load Adelaide University
adelaide = Institution.where({
               :id => 2,
               :code => 'adelaide'
           }).first_or_create!

adelaide.name = 'Adelaide University'
adelaide.nickname = 'Adelaide'
adelaide.country = 'Australia'
adelaide.state = 'SA'

adelaide.save

# Load Uni SA
uni_sa = Institution.where({
               :id => 3,
               :code => 'uni_sa'
           }).first_or_create!

uni_sa.name = 'University of South Australia'
uni_sa.nickname = 'UniSA'
uni_sa.country = 'Australia'
uni_sa.state = 'SA'

uni_sa.save

InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "HY1", :name => "Half Year 1").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "HY2", :name => "Half Year 2").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "NS", :name => "Non Semester").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "NS1", :name => "Non Semester 1").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "NS2", :name => "Non Semester 2").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "S1", :name => "Semester 1").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "S2", :name => "Semester 2").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "TH1", :name => "Thesis 1").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "TH2", :name => "Thesis 2").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "HY1", :name => "Half Year 1").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "HY2", :name => "Half Year 2").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "NS", :name => "Non Semester").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "NS1", :name => "Non Semester 1").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "NS2", :name => "Non Semester 2").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "S1", :name => "Semester 1").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "S2", :name => "Semester 2").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "TH1", :name => "Thesis 1").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2013, :code => "TH2", :name => "Thesis 2").first_or_create
InstitutionSemester.where(:institution => flinders, :year => 2014, :code => "SU", :name => "Summer School").first_or_create

InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "S1", :name => "Semester 1").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "S2", :name => "Semester 2").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "Term1", :name => "Term 1").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "Term2", :name => "Term 2").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "Term3", :name => "Term 3").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "Term4", :name => "Term 4").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "Tri1", :name => "Trimester 1").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "Tri2", :name => "Trimester 2").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "Wi", :name => "Winter School").first_or_create
InstitutionSemester.where(:institution => adelaide, :year => 2014, :code => "Su", :name => "Summer School").first_or_create

InstitutionSemester.where(:institution => uni_sa, :year => 2014, :code => "SP4", :name => "Study Period 4").first_or_create
InstitutionSemester.where(:institution => uni_sa, :year => 2014, :code => "SP5", :name => "Study Period 5").first_or_create
InstitutionSemester.where(:institution => uni_sa, :year => 2014, :code => "SP6", :name => "Study Period 6").first_or_create
InstitutionSemester.where(:institution => uni_sa, :year => 2014, :code => "SP7", :name => "Study Period 7").first_or_create
