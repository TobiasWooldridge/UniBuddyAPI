namespace :timetables_test do
  desc "Update class timetables from the Adelaide University website"

  task :update => :environment do |t, args|
    desc "Update"

    year = Date.today.strftime("%Y")

    puts "Scraping timetables for %s" % year
    @agent = Mechanize.new

    scrape_timetables_from_url "https://cp.adelaide.edu.au/courses/search.asp"
    #page = @agent.get("https://cp.adelaide.edu.au/courses/details.asp?year=2014&course=104229+1+3410+1")
    #process_timetable page/"div[id=\"hidedata04_1\"] >table:first", "faketopic"
  end

  private
  agent = nil

  def get_timetable_form page
    page.form_with(:action => /search\.asp/)
  end

  def scrape_timetables_from_url url
    page = @agent.get url
    form = get_timetable_form page
    subject_area_widget = form.field_with(:name => 'subject')
    subject_area_widget.options.from(1).each do |entry|
      subject_code = entry.value
      name = entry.text.split(/- /).second

      subject_area_widget.value = entry
      begin
        page = form.submit
        scrape_topics_on_page page
      rescue => error
        begin
          page = form.submit
          scrape_topics_on_page page
        rescue => error_two
          puts "Error #{$!} while importing %s" % name
          puts error.backtrace
        end
      end
    end
  end

  def scrape_topics_on_page page
    topic_links = page/'div[class="content"] a'

    topic_links.each do |topic_link|
      if topic_link['href'].to_s.match(/^details.asp/).nil?
        next
      end

      begin
        url = topic_link['href'].to_s
        scrape_topic_page_from_url url
      rescue => error
        puts "Error #{$!} while importing %s" % topic_link['href']
        puts error.backtrace
      end
    end
  end

  def scrape_topic_page_from_url url
    page = @agent.get(url)
    topic_full_name_raw = (page/"div[class=\"content\"] h1:first").text.split(/ - /)
    topic_full_name = topic_full_name_raw.second.squish

    puts "Scraping topic %s" % topic_full_name

    topic_title_meta_raw = topic_full_name_raw.first
    topic_title_meta = /^(?<Subject Area>[a-z ]+)(?<Topic Number>[0-9]+[a-z]*)$/i.match topic_title_meta_raw

    topic_meta_table_rows = page/"div[id=\"hidedata01_1\"] > table > tr"

    topic_meta = Hash.new

    topic_meta["Subject Area"] = topic_title_meta["Subject Area"].strip
    topic_meta["Topic Number"] = topic_title_meta["Topic Number"]
    topic_meta["Name"] = topic_full_name

	  #Topic coordinators on a seperate page http://www.adelaide.edu.au/course-outlines/013637/1/sem-1/
	  #The number can be found in the timetable request link
	  #sem-2 for semester 2 etc
      #topic_meta["Coordinator"] = (page/"div.container h2:first").first.next_sibling.next_sibling.text.strip

      topic_meta_table_rows.each do |table_row|
        if !(table_row/"th:first").children.empty?
          label = (table_row/"th:first").children.first.text.tr(":","").squish
        else
          label = (table_row/"th:first").text.tr(":","").squish
        end
        value = (table_row/"td:first").text.squish

        topic_meta[label] = value
      end

      meta = topic_meta.deep_dup

      meta_table = (page/"div[class=\"content\"] > table:first")
      meta_table_headings = meta_table/"tr:nth-of-type(2) th"
      meta_table_values = meta_table/"tr:nth-of-type(3) td"

      meta_table_headings.length.times do |x|
        if !meta_table_headings[x].children.empty?
          heading = meta_table_headings[x].children.first.text.squish
        else
          heading = meta_table_headings[x].text.squish
        end
        if x == 2 or x == 3
            #Money then band
            value = meta_table_values[x+1].text.squish + " " + meta_table_values[x].text.squish
            meta_table_values.delete(meta_table_values[x+1])
          else
            value = meta_table_values[x].text.squish
          end
          meta[heading] = value
        end
		#GET THIRD TABLE
		meta_table_dates = (page/"div[class=\"content\"] table:nth-of-type(4)")
		meta_table_dates_headings = meta_table_dates/"tr:first th"
		meta_table_dates_values = meta_table_dates/"tr:last td"
		
		meta_table_dates_headings.length.times do |x|
      if !meta_table_dates_headings[x].children.empty?
        heading = meta_table_dates_headings[x].children.first.text.squish
      else
        heading = meta_table_dates_headings[x].text.squish
      end
      value = meta_table_dates_values[x].text.squish

      meta[heading] = value
    end
=begin
    topic = Topic.where(
      :subject_area => topic_title_meta["Subject Area"],
      :topic_number => topic_title_meta["Topic Number"],
      :year => meta["Year"],
      :semester => meta["Term"],
      :location => meta["Campus"]
      ).first_or_initialize

    topic.name = meta["Name"]
    topic.units = meta["Units"]
        #Have to code seperate method to get
        #topic.coordinator = meta["Coordinator"]
        topic.description = meta["Syllabus"]
        #Not available afaik
        #topic.learning_outcomes = meta["Expected Learning Outcomes"]
        topic.assumed_knowledge = meta["Assumed Knowledge"]
        topic.assessment = meta["Assessment"]      
        topic.class_contact = meta["Contact"]
        topic.institution = Institution.adelaide
        #seemingly not available
        #topic.enrolment_opens = meta["First day to enrol"]
		#Have to format to Flinders date of 02 Dec 2013?
    topic.enrolment_closes = meta["Last day to Add Online"]

        # Wrap up our changes to the topic here
        topic.save
=end
        # Now create/update all child objects
        topic = "asdf" #DELETE ME
        process_timetable page/"div[id=\"hidedata04_1\"] >table:first", topic


#        verb = topic.new_record? ? "Saving" : "Updating"
#        puts "%s topic %s (%s %s) (%s)" % [verb, topic.code, topic.year, topic.semester, topic.name]
end

def process_timetable timetable, topic
  rows = timetable/"tr"
  groupNumber = ""
  totalPlacesAvailable = ""
  placesLeft = ""
  classNumber = ""
  full = false
  class_group = nil
  class_type = nil
  rows.length.times do |i|
    puts "i is: %i" % i
    rowTh = (rows[i]/"th")
          if rowTh.length == 1  #Having colspan 8 means its a new class type!
            puts "Found new class type"
#           class_type = ClassType.where(
#             :topic => topic,
#             :name => rowTh.text.split(": ")[1].squish
#             ).first_or_initialize

#            class_type.save
          elsif rows[i]["class"] == "trheader" #It's the funny header thing
              #Maybe save names and put stuff to table with names?
              puts "Found column names. Skipping..."
              next
            elsif rows[i]["class"] =="data" and (rows[i]/"td").length == 8 #It's actual class stuff, for the first time
              puts "First instance of new class data"
              cells = rows[i]/"td"
              groupNumber = cells[1].text.squish
              classNumber = cells[0].text.squish
              totalPlacesAvailable = cells[2].text.squish
              placesLeft = cells[3].text.squish
              puts "DEBUG current class size %s" % placesLeft
              full = (placesLeft.include?("FULL"))
              puts full

#              class_group = ClassGroup.where(
#                :class_type => class_type,
#                :group_number => groupNumber #Of the form LE01, TU01 etc... bad? originally a number
#                ).first_or_initialize
#              ClassSession.where(:class_group => class_group).delete_all
#              class_group.note = cells[3].text #The size of the class
                #CANNOT REPLICATE
                #class_group.full = full && Time.now > topic.enrolment_opens
#                class_group.full = full

                # Create new ClassSession
                date_range = cells[4].text.split(" - ")
                time_range = cells[6].text.split("-")

                room_details = cells[7].text.squish.split(', ')
                room_name = room_details[2]
                room_id = room_details[1]
                room_general_location = room_details[0]
                puts room_name
                puts room_id
                puts room_general_location

                #Normally join room at Flinders, but not needed here
                #Maybe make a new room?
                #if room_details.length == 3
                #  room = Room.joins(:building).where("buildings.name = ? AND rooms.code = ?", room_details[0], room_details[1]).first_or_initialize
                #end

                time_starts_at = Time.parse(time_range[0].strip) - Time.now.at_beginning_of_day
                time_ends_at = Time.parse(time_range[1].strip) - Time.now.at_beginning_of_day

                puts time_starts_at
                puts time_ends_at

                puts Date.parse(date_range[0].strip)
                puts Date.parse(date_range[1].strip)
                puts Date.parse(cells[5].text.strip).strftime('%u')

#                class_session = ClassSession.new(
#                  :class_group => class_group,
#                  :first_day => Date.parse(date_range[0].strip),
#                  :last_day => Date.parse(date_range[1].strip),
#                  :day_of_week => Date.parse(cells[1].text.strip).strftime('%u'),
#                  :time_starts_at => time_starts_at,
#                  :room_id => room.nil? ? nil : room.id
#                  )            
#                if !class_session.new_record?
#                  puts "Joining adjacent class sessions for %s %s" % [topic.name, class_type.name]
#                end
#                class_session.time_ends_at = time_ends_at

#                class_session.save
            elsif (rows[i]/"td").length == 4 # The non data one but still containing values
              cells = rows[i]/"td"
              puts "Another row of class data"
              date_range = cells[0].text.split(" - ")
              time_range = cells[2].text.split("-")

              room_details = cells[3].text.squish.split(', ')
              room_name = room_details[2]
              room_id = room_details[1]
              room_general_location = room_details[0]
              puts room_name
              puts room_id
              puts room_general_location

              #Normally join room at Flinders, but not needed here
              #Maybe make a new room?

              time_starts_at = Time.parse(time_range[0].strip) - Time.now.at_beginning_of_day
              time_ends_at = Time.parse(time_range[1].strip) - Time.now.at_beginning_of_day

              puts time_starts_at
              puts time_ends_at

              puts Date.parse(date_range[0].strip)
              puts Date.parse(date_range[1].strip)
              puts Date.parse(cells[1].text.strip).strftime('%u')

              #Gets old class time to see if starts at is ends at
#              class_session = ClassSession.where(
#                :class_group => class_group,
#                :first_day => Date.parse(date_range[0].strip),
#                :last_day => Date.parse(date_range[1].strip),
#                :day_of_week => Date.parse(cells[1].text.strip).strftime('%u'),
#                :time_ends_at => time_starts_at,
#                :room_id => room.nil? ? nil : room.id
#                ).first
              #Otherwise not adjacent and no joining
#              class_session = class_session || ClassSession.new(
#                :class_group => class_group,
#                :first_day => Date.parse(date_range[0].strip),
#                :last_day => Date.parse(date_range[1].strip),
#                :day_of_week => Date.parse(cells[1].text.strip).strftime('%u'),
#                :time_starts_at => time_starts_at,
#                :room_id => room.nil? ? nil : room.id
#                )            
              #What if sessions are not new but not adjacent?
              #E.g. https://cp.adelaide.edu.au/courses/details.asp?year=2014&course=104229+1+3410+1
#              if !class_session.new_record?
#                puts "Joining adjacent class sessions for %s %s" % [topic.name, class_type.name]
#              end
#              class_session.time_ends_at = time_ends_at

#              class_session.save
            #Grab only dates, days, time, location here
            #Store section, total size, classnumber and available in variables one level up
            #And access from there
          elsif (rows[i]/"td").length == 5
            puts "Found a class with no details available"
            cells = rows[i]/"td"
            groupNumber = cells[1].text.squish
            classNumber = cells[0].text.squish
            totalPlacesAvailable = cells[2].text.squish
            placesLeft = cells[3].text.squish
            puts "DEBUG current class size %s" % placesLeft
            full = (placesLeft.include?("FULL"))
            puts full
#              class_group = ClassGroup.where(
#                :class_type => class_type,
#                :group_number => groupNumber #Of the form LE01, TU01 etc... bad? originally a number
#                ).first_or_initialize
#              ClassSession.where(:class_group => class_group).delete_all
                #CANNOT REPLICATE
                #class_group.full = full && Time.now > topic.enrolment_opens
#                class_group.full = full

elsif (rows[i]/"td").length == 1
  puts "Found a notes section"
#              class_group.note = cells[4].text #The size of the class
#              class_session = ClassSession.new(
#                :class_group => class_group,
#                :first_day => nil,
#                :last_day => nil,
#                :day_of_week => nil,
#                :time_starts_at => nil,
#                :room_id => nil
#                )     
#              class_session.save
else
  puts "Found an unknown type of row"
  puts row[i]
end
end
end
end