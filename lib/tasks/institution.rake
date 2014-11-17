namespace :institution do
  task :create, [:name, :nickname, :country, :state, :code] => :environment do |t, args|
    Institution.create(:name => args[:name], :nickname => args[:nickname], :country => args[:country], :state => args[:state], :code => args[:code])
  end


  task :label_semesters, [:code, :headless] => :environment do |t, args|
    semesters = InstitutionSemester.where("name IS NULL")

    if args[:headless].nil?
      semesters.each do |semester|
        print "%s\t%s\t%s\n" % [semester.institution.code, semester.year, semester.code]

        semester.name = InstitutionSemester.code_to_name(semester.code)

        if (semester.name.nil?)
          p InstitutionSemester.code_to_name(semester.code)
          print "\tWhat do you want to call this semester? "
          semester.name = $stdin.gets.strip.titlecase
        else
          print "\tRecycled name %s\n" % semester.name
        end

        semester.save
      end
    end
  end


  task :add_semesters, [] => :environment do |t, args|
    semesters = Topic.select('institution_id, year, semester').group('institution_id, year, semester')
    semesters.each do |semester|
      if semester.year == nil or semester.semester == nil then
        next
      end

      instSemester = InstitutionSemester.where(:institution_id => semester.institution_id, :year => semester.year, :code => semester.semester).first_or_initialize

      if not instSemester.new_record?
        next
      end

      instSemester.name = InstitutionSemester.code_to_name(instSemester.code)

      p instSemester

      instSemester.save
    end
  end
end
