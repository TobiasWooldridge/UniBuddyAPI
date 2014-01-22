namespace :institution do
  task :create, [:name, :nickname, :country, :state, :code] => :environment do |t, args|
    Institution.create(:name => args[:name], :nickname => args[:nickname], :country => args[:country], :state => args[:state], :code => args[:code])
  end


  task :populate_semesters, [:code, :headless] => :environment do |t, args|
    populated_institution_semesters = []

    if (args[:code].nil?)
      Institution.all.each do |institution|
        institution.populate_semesters

        populated_institution_semesters.concat(institution.institution_semesters)
      end
    else
      institution = Institution.where(:code => args[:code]).first

      institution.populate_semesters

      populated_institution_semesters.concat(institution.institution_semesters)
    end



    if args[:headless].nil?
      populated_institution_semesters.each do |semester|
        semester.attempt_to_populate_name
        semester.reload

        print "%s\t%s\t%s\t%s\n" % [semester.institution.code, semester.year, semester.code, semester.name || "Unknown semester name"]

        if (semester.name.nil?)
          print "What do you want to call this semester? "
          semester.name = $stdin.gets.strip
          semester.save
        end
      end
    end
  end
end
