namespace :institution do
  task :create, [:name, :nickname, :country, :state, :code] => :environment do |t, args|
    Institution.create(:name => args[:name], :nickname => args[:nickname], :country => args[:country], :state => args[:state], :code => args[:code])
  end

  task :update_semesters, [] => :environment do |t, args|
    semesters = Topic.select('institution_id, year, semester').group('institution_id, year, semester')
    semesters.each do |semester|
      if semester.year == nil or semester.semester == nil then
        next
      end

      if Time.now.year > semester.year
        # Ignore old years
        p "Skipping semester with year %s" % semester.year
        next
      elsif /^TH.*$/.match(semester.semester)
        # Hack to skip thesis topics
        p "Skipping semester with semester code %s" % semester.semester
        next
      end

      instSemester = InstitutionSemester.where(:institution_id => semester.institution_id, :year => semester.year, :code => semester.semester).first_or_initialize
      instSemester.name = InstitutionSemester.code_to_name(instSemester.code)

      if (instSemester.name.nil?)
        print "%s\t%s\t%s\n" % [instSemester.institution.code, instSemester.year, instSemester.code]
        p InstitutionSemester.code_to_name(instSemester.code)
        print "\tWhat do you want to call this semester? "
        instSemester.name = $stdin.gets.strip.titlecase
      else
        print "\tRecycled name %s\n" % instSemester.name
      end

      p instSemester

      instSemester.save
    end
  end
end
