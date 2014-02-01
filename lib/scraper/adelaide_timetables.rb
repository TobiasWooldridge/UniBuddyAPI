module Scraper
  module AdelaideTimetables
    def get_timetable_form page
      # Getting the year from the table heading
      @year = (page/'li[id="current"] a').text.match('[0-9]+')[0].to_i

      page.form_with(:action => /search\.asp/)
    end

    def scrape_timetables_from_url url
      page = @agent.get url
      form = get_timetable_form page
      
      subject_area_widget = form.field_with(:name => 'subject')
      subject_area_widget.options.from(1).each do |entry|

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
            @logger.error "Error # {$!} while importing %s" % name
            @logger.error error.backtrace
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
          @logger.error "Error # {$!} while importing %s" % topic_link['href']
          @logger.error error.backtrace
        end
      end
    end

    def scrape_topic_page_from_url url
      page = @agent.get(url)
      topic_full_name_raw = (page/"div[class=\"content\"] h1:first").text.split(/ - /, 2)
      topic_full_name = topic_full_name_raw.second.squish

      @logger.info "Scraping topic %s" % topic_full_name

      topic_title_meta_raw = topic_full_name_raw.first
      topic_title_meta = /^(?<Subject Area>[a-z& ]+)(?<Topic Number>[0-9]+[a-z&]*)$/i.match topic_title_meta_raw

      topic_meta_table_rows = page/"div[id=\"hidedata01_1\"] > table > tr"

      meta = Hash.new

      meta["Subject Area"] = topic_title_meta["Subject Area"].strip
      meta["Topic Number"] = topic_title_meta["Topic Number"]
      meta["Name"] = topic_full_name

      @logger.debug ({
        'Subject Area' => meta["Subject Area"],
        'Topic Number' => meta["Topic Number"]
      })

      # Topic coordinators on a seperate page http://www.adelaide.edu.au/course-outlines/013637/1/sem-1/
      # The number can be found in the timetable request link
      # sem-2 for semester 2 etc
      # meta["Coordinator"] = (page/"div.container h2:first").first.next_sibling.next_sibling.text.strip

      topic_meta_table_rows.each do |table_row|

        # First we grab the course metadata
        if !(table_row/"th:first").children.empty?
          # Handle the case when the row identifier is a link (as it has a child <a> element with the actual text)
          label = (table_row/"th:first").children.first.text.tr(":", "").squish
        else
          label = (table_row/"th:first").text.tr(":", "").squish
        end
        value = (table_row/"td:first").text.squish

        meta[label] = value
        @logger.debug "Course info table heading %s has value %s" % [label, meta[label]]
      end

      # Grab the course fee stuff
      meta_table = (page/"div[class=\"content\"] > table:first")
      meta_table_headings = meta_table/"tr:nth-of-type(2) th"
      meta_table_values = meta_table/"tr:nth-of-type(3) td"

      meta_table_headings.length.times do |x|
        if !meta_table_headings[x].children.empty?
          heading = meta_table_headings[x].children.first.text.squish
        else
          heading = meta_table_headings[x].text.squish
        end

        # Since money and band are split here, but not in the Flinders scraper
        # we join them together, and then remove the monetary value
        if x == 2 or x == 3
          value = meta_table_values[x+1].text.squish + " " + meta_table_values[x].text.squish
          meta_table_values.delete(meta_table_values[x+1])
        else
          value = meta_table_values[x].text.squish
        end
        meta[heading] = value
        @logger.debug "Course fees table heading %s has value %s" % [heading, meta[heading]]
      end

      # Grab critical dates
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
        @logger.debug "Critical dates table heading %s has value %s" % [heading, meta[heading]]
      end

      #Translate from Adelaide Uni Semester to semesters as in DB
      semesterTranslation = {"Term 1" => "Term1", "Term 2" => "Term2", "Term 3" => "Term3",
       "Term 4" => "Term4", "Trimester 1" => "Tri1", "Trimester 2" => "Tri2", "Trimester 3" => "Tri3", "Summer School" => "Su", "Winter School" => "Wi", "Semester 1" => "S1", "Semester 2" => "S2"}

      @logger.debug "Translated semester is %s" % semesterTranslation[meta["Term"]]
      topic = Topic.where(
       :subject_area => meta["Subject Area"].squish,
       :topic_number => meta["Topic Number"],
       :year => @year,
       :semester => semesterTranslation[meta["Term"]],
      # :location => meta["Campus"]
      ).first_or_initialize

      @logger.debug "Is this a new record? %s" % topic.new_record?

      topic.name = meta["Name"]
      topic.units = meta["Units"]
      topic.description = meta["Syllabus"]
      topic.assumed_knowledge = meta["Assumed Knowledge"]
      topic.assessment = meta["Assessment"]
      topic.class_contact = meta["Contact"]
      topic.institution = Institution.adelaide

      topic.enrolment_closes = meta["Last day to Add Online"]

      # Wrap up our changes to the topic here
      topic.save

      # Now create/update all timetable data
      process_timetable page/"div[id=\"hidedata04_1\"] >table:first", topic
    end

    def process_timetable timetable, topic
      rows = timetable/"tr"
      groupNumber = ""
      totalPlacesAvailable = ""
      placesLeft = ""
      classNumber = ""
      class_session = nil
      full = false
      sync_selection = nil
      class_group = nil
      class_type = nil

      rows.length.times do |i|
        @logger.debug "Current row number being processed is: %i" % i
        rowTh = (rows[i]/"th")
        rowThSplit = rowTh.text.split(": ")

        # If it's just one header, it's new class type
        if rowTh.length == 1 

          # If we have a heading but no actual class type skip
          if rowThSplit.length != 2 
            next
          end

          @logger.debug "Found new class type"
          classTypeName = rowThSplit[1].squish
          @logger.debug "Class type name is %s" % classTypeName
          class_type = ClassType.where(
            :topic_id => topic,
            :name => classTypeName
            ).first_or_initialize

          class_type.save

        # Topic requiring sync_selections_id to be non-nil as if you pick
        # Lecture 01, you get Tute01 and Prac01 as well
        elsif rows[i]["class"] == "trgroup"
          if sync_selection == nil
            @logger.debug "Found one of those grouping topics. Assuming all classes should be grouped by class number..."
            sync_selection = SelectionSync.new(
              :topic => topic)
            sync_selection.save
          end

        # It's the colum descriptions, and we can skip them
        elsif rows[i]["class"] == "trheader" 
          @logger.debug "Found column names. Skipping..."
          next

        # It's the first row of actual class data
        elsif rows[i]["class"] =="data" and (rows[i]/"td").length == 8 
          @logger.debug "First instance of new class data row"
          cells = rows[i]/"td"
          groupNumber = nil
          groupNumber_raw = (cells[1].text.squish.match "[0-9]+")

          if !(groupNumber_raw == nil)
            groupNumber = groupNumber_raw[0].to_i.to_s
          else
            groupNumber = cells[1].text.squish.slice(2..cells[1].text.length).hash
            @logger.debug "No number in groupNumber... Hash of %s used instead # YOLO" % groupNumber
          end

          classNumber = cells[0].text.squish
          totalPlacesAvailable = cells[2].text.squish
          placesLeft = cells[3].text.squish
          full = (placesLeft.include?("FULL"))

          @logger.debug ({
              "Group Number" => groupNumber,
              "Class Number" => classNumber,
              "Total Places Available" => totalPlacesAvailable,
              "Places Left" => placesLeft,
              "Full" => full,
              "Sync selection" => sync_selection
          })

          class_group = ClassGroup.where(
            :class_type => class_type,
              :group_number => groupNumber
              ).first_or_initialize
          Activity.where(:class_group => class_group).delete_all
          class_group.note = placesLeft
          class_group.synced_selections_id = sync_selection
         
          # Enrolment opening info not available from Adelaide, so we will just settle
          # for if the class is full or not
          class_group.full = full

          date_range = cells[4].text.split(" - ")
          time_range = cells[6].text.split(" - ")

          room_details = cells[7].text.squish.split(', ')
          room_name = room_details[2]
          room_id = room_details[1]
          room_general_location = room_details[0]
          @logger.debug "Room name is: %s" % room_name
          @logger.debug "Room id is: %s" % room_id
          @logger.debug "Room general location is: %s" % room_general_location

          # TODO: Make new room if room does not exist
          if room_details.length == 3
            room = Room.joins(:building).where("buildings.name = ? AND rooms.code = ?", room_general_location, room_id).first_or_initialize
          end

          # If we have a valid time in the time cell of the table
          if (time_range.length == 2)
            time_starts_at = Time.parse(time_range[0].strip) - Time.now.at_beginning_of_day
            time_ends_at = Time.parse(time_range[1].strip) - Time.now.at_beginning_of_day
          else
            time_starts_at = nil
            time_ends_at = nil
          end

          @logger.debug "Class session starts at: %s" % time_starts_at
          @logger.debug "Class session ends at: %s" % time_ends_at

          firstDay = Date.parse(date_range[0].strip)
          lastDay = Date.parse(date_range[1].strip)

          # If we have a valid day in the day cell of the table
          if !(cells[5].text == "")
            dayOfWeek = Date.parse(cells[5].text.strip).strftime('%u')
          else
            dayOfWeek = nil
          end

          @logger.debug "First day of class session: %s" % firstDay
          @logger.debug "Last day of class session: %s" % lastDay
          @logger.debug "Weekday of class session: %s" % dayOfWeek

          # Create a new activity to hold the class
          class_session = Activity.new(
            :class_group => class_group,
            :first_day => firstDay,
            :last_day => lastDay,
            :day_of_week => dayOfWeek,
            :time_starts_at => time_starts_at,
            :room_id => room.nil? ? nil : room.id
            )
          if !class_session.new_record?
            @logger.debug "Joining adjacent class sessions for %s %s" % [topic.name, class_type.name]
          end
          class_session.time_ends_at = time_ends_at

          class_session.save
          # Another class row, that is not the first one
        elsif (rows[i]/"td").length == 4 
          cells = rows[i]/"td"
          @logger.debug "Another class data row"
          date_range = cells[0].text.split(" - ")
          time_range = cells[2].text.split("-")

          room_details = cells[3].text.squish.split(', ')
          room_name = room_details[2]
          room_id = room_details[1]
          room_general_location = room_details[0]

          @logger.debug "Room name is: %s" % room_name
          @logger.debug "Room id is: %s" % room_id
          @logger.debug "Room general location is: %s" % room_general_location

          # TODO: Make new room if room does not exist
          if room_details.length == 3
            room = Room.joins(:building).where("buildings.name = ? AND rooms.code = ?", room_general_location, room_id).first_or_initialize
          end

          # If we have a valid time in the time cell of the table
          if (time_range.length == 2)
            time_starts_at = Time.parse(time_range[0].strip) - Time.now.at_beginning_of_day
            time_ends_at = Time.parse(time_range[1].strip) - Time.now.at_beginning_of_day
          else
            time_starts_at = nil
            time_ends_at = nil
          end

          @logger.debug "Class session starts at: %s" % time_starts_at
          @logger.debug "Class session ends at: %s" % time_ends_at

          firstDay = Date.parse(date_range[0].strip)
          lastDay = Date.parse(date_range[1].strip)

          #If we have a valid day in the day cell of the table
          if !(cells[1].text == "")
            dayOfWeek = Date.parse(cells[1].text.strip).strftime('%u')
          else
            dayOfWeek = nil
          end

          @logger.debug "First day of class session: %s" % firstDay
          @logger.debug "Last day of class session: %s" % lastDay
          @logger.debug "Weekday of class session: %s" % dayOfWeek

          # Gets old class time to see if starts at is ends at
          class_session = Activity.where(
            :class_group => class_group,
            :first_day => firstDay,
            :last_day => lastDay,
            :day_of_week => dayOfWeek,
            :time_ends_at => time_starts_at,
            :room_id => room.nil? ? nil : room.id
            ).first

          # Otherwise not adjacent and no joining
          class_session = class_session || Activity.new(
            :class_group => class_group,
            :first_day => firstDay,
            :last_day => lastDay,
            :day_of_week => dayOfWeek,
            :time_starts_at => time_starts_at,
            :room_id => room.nil? ? nil : room.id
            )

          #If start times of class is same as end time of old one
          if !class_session.new_record?
            @logger.debug "Joining adjacent class sessions for %s %s" % [topic.name, class_type.name]
          end
          class_session.time_ends_at = time_ends_at

          class_session.save

        # Class that has no details available
        elsif (rows[i]/"td").length == 5
          @logger.debug "Found a class with no details available"
          cells = rows[i]/"td"
          groupNumber = nil
          groupNumber_raw = (cells[1].text.squish.match "[0-9]+")
          if !(groupNumber_raw == nil)
            # to_i removes leading 0
            groupNumber = groupNumber_raw[0].to_i.to_s
          else
            groupNumber = cells[1].text.squish.slice(2..cells[1].text.length).hash
            @logger.debug "No number in groupNumber... Hash of %s used instead # YOLO" % groupNumber
          end

          classNumber = cells[0].text.squish
          totalPlacesAvailable = cells[2].text.squish
          placesLeft = cells[3].text.squish
          full = (placesLeft.include?("FULL"))

          @logger.debug "Group number is: %s" % groupNumber
          @logger.debug "Class number is: %s" % classNumber
          @logger.debug "Total places available is: %s" % totalPlacesAvailable
          @logger.debug "Places left in class: %s" % placesLeft
          @logger.debug "Is this class full? %s" % full
          @logger.debug "Selection sync object: %s" % sync_selection


          @logger.debug ({
            "Group Number" => groupNumber,
            "Class Number" => classNumber,
            "Total Places Available" => totalPlacesAvailable,
            "Places Left" => placesLeft,
            "Full" => full,
            "Sync selection" => sync_selection
          })

          class_group = ClassGroup.where(
            :class_type => class_type,
              :group_number => groupNumber
              ).first_or_initialize
          Activity.where(:class_group => class_group).delete_all
          class_group.synced_selections_id = sync_selection

          # Not available from Adelaide data. Just going with full
          class_group.full = full

        # Adelaide Uni problem with Autoenrolment
        # We can just ignore it
        elsif (rows[i]/"td").length == 1
          if i == 0
            @logger.warn "Conflicting auto enrolment sections found..."
            next
          end

          # If i is not 0 we have found a notes section
          @logger.debug "Found a notes section"
          class_type.note = cells[0].text
          class_type.save

        # Unknown row type
        else
          @logger.warn "Found an unknown type of row"
          @logger.warn row[i]
        end
      end
    end
  end

end
