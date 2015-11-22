namespace :institution do
  task :create, [:name, :nickname, :country, :state, :code] => :environment do |t, args|
    Institution.create(:name => args[:name], :nickname => args[:nickname], :country => args[:country], :state => args[:state], :code => args[:code])
  end

  task :update_semesters, [] => :environment do |t, args|

    args.with_defaults(:headless => false)

    semesters = Topic.select('institution_id, year, semester').joins(:class_types).group('institution_id, year, semester')
    semesters.each do |semester|
      if semester.year == nil or semester.semester == nil then
        next
      end

      # Verify if this is a legit semester
      if Time.now.year > semester.year
        # Ignore old years
        # p "Skipping semester with year %s" % semester.year
        next
      elsif /^TH.*$/.match(semester.semester)
        # Hack to skip thesis topics
        # p "Skipping semester with semester code %s" % semester.semester
        next
      end

      # Create a new InstitutionSemester object to represent this
      instSemester = InstitutionSemester.where(:institution_id => semester.institution_id, :year => semester.year, :code => semester.semester).first_or_initialize

      # Try to pull the semester name from a previous semester (S2 will always be Semester 2)
      instSemester.name = InstitutionSemester.code_to_name(instSemester.code)

      if instSemester.name.nil?
        print "%s\t%s\t%s\n" % [instSemester.institution.code, instSemester.year, instSemester.code]
        if args.headless
          print "Skipping due to headless mode"
          next
        end
        print "What do you want to call this semester? "
        instSemester.name = $stdin.gets.strip.titlecase
      elsif instSemester.new_record?
        print "Recycled name %s\n" % instSemester.name
      end


      if not instSemester.persisted?
        p instSemester
        instSemester.save
      end

    end
  end
end
