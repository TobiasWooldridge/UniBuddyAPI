module Scraper
  module UnisaTimetables 
    def scrape_topics subject_area
      search_page = @agent.get 'http://programs.unisa.edu.au/public/pcms/Home.aspx?tid=494'
      if (search_page.forms.size != 1)
        @logger.error "Too many forms on search page - maybe it's changed?"
        return
      end
      search_form = search_page.forms.first
      courses_radiobutton = search_form.radiobutton_with(:text => "Courses")
      if(courses_radiobutton == nil)
        @logger.error "Unable to find courses radio button"
        return
      end
      courses_radiobutton.check
      search_text = search_form.texts.select {|text| text.name =~ /txtSearch/ }.first 
      if (search_text == nil)
        @logger.info "Unable to find search text field..."
        return
      end
      # The string "[" seems to return more results, but breaks the search
      search_text.value = subject_area
      results_page = search_form.submit(search_form.buttons.first)
      page_num = 1
      loop do
        # Find all course links on page. Only take ones that look like a subject code to reduce duplication as there are links by name and code
        results_page.links_with(:href => /course.aspx/, :text => /[A-Z]{4} [0-9]{4}/).each do |link|
          @logger.info "Scraping #{link.text}"
          course_page = link.click
          scrape_course course_page
        end
        next_link = results_page.link_with(:text => "Next >")
        if (next_link != nil)
          results_page = next_link.click
          page_num += 1
          @logger.debug "Scraping page #{page_num}"
        else
          break
        end
      end
      @logger.info "Scraping complete!"
    end

    def scrape_course course_page
      timetable_links = course_page.links_with(:href => /timetable.unisa.edu.au/)
      if(timetable_links.size == 0)
        @logger.debug "No timetables found. Maybe it's not up yet or even offered this year?"
      else
        timetable_links.each do |link|
          @logger.info "Scraping #{link.text} timetable"
          timetable_page = link.click
          scrape_course_timetable timetable_page
        end
      end
    end

    def format_study_period study_period_number
      return 'SP%d' % study_period_number
    end

    def scrape_course_timetable timetable_page
      # Scrape topic info relevant to all options
      topic_name = timetable_page.search("#ctl00_cpWebPage_lblCourseName").text.squish
      
      subject_area_catalogue_number = timetable_page.search("#ctl00_cpWebPage_lblSubjAreaCatNbr").text
      subject_area, topic_number = subject_area_catalogue_number.match(/([A-Z]{4}) ([0-9]{4})/).captures

      study_period_and_year = timetable_page.search("#ctl00_cpWebPage_lblStudyPeriod").text
      study_period_raw, year_raw = study_period_and_year.match(/.* ([0-9]) - ([0-9]{4})/).captures

      study_period = format_study_period study_period_raw
      year = year_raw.to_i

      @logger.debug "Topic with name: #{topic_name}, subject area: #{subject_area}, topic number: #{topic_number}, study period: #{study_period}, year: #{year}"

      timetable = timetable_page.search(".ClassTimeTable")
      if (timetable == nil)
        @logger.error "Unable to find timetable on page. Has structure changed?"
       return
      end

      # Vars required for topic definition
      option_name = nil
      option_campus = nil

      # Vars required for class definition
      topic = nil

      # Iterate over options in timetable
      timetable_rows = timetable.children
      timetable_rows.select {|row| !row.text?}.each do |row|

        catch :invalidclass do
          row_class = row['class']
          case row_class
          when "OptionRow"
            #@logger.trace "Found an option row!"
            option_name = row.search(".OptionNumber").text
            # Reset option state - this seems fragile
            option_campus = nil
            topic = nil
          when "ClassTypeRow"
            #@logger.trace "Found a class name row!" 
            #component = row.search(".ClassType").text.match(/.* - (.*)/).captures[0].squish
          when "HeadingLG"
            #@logger.trace "Found a heading row"
            # nop
          when nil, "alternate"
            #@logger.trace "Found an information row"

            timetable_columns = row.children.select {|row| !row.text?}
            campus_column = timetable_columns[TimetableColumn::CAMPUS]
            # handle case where it is on a link
            campus = campus_column.search("a").text
            if(campus == "")
                campus = campus_column.text
            end
            # handle no link case
            if(campus == "")
              @logger.error "Unable to get campus!"
            end
            # Only set the campus if we haven't set it already
            if (option_campus == nil)
              option_campus = campus
            else
              if (campus != option_campus)
                @logger.error "Option found that has multiple campuses. Need to add support for this!"
                break
              end
            end
            attendance = timetable_columns[TimetableColumn::ATTENDANCE].text
            class_component = timetable_columns[TimetableColumn::COMPONENT].text

            # Skip external components as they usually don't have timetable info?
            if(class_component == "External")
              @logger.debug "Skipping external class"
              throw :invalidclass
            elsif(attendance == "On Line")
              @logger.debug "Skipping online class"
              throw :invalidclass
            else
              # Only save options if not external and not saved before
              if(topic == nil)
                topic = save_topic(topic_name, option_name, option_campus, subject_area, topic_number, year, study_period)
              end
            end
            class_number = timetable_columns[TimetableColumn::CLASS_NUMBER].text.to_i
            class_size = timetable_columns[TimetableColumn::CLASS_SIZE].text.to_i
            students_enrolled = timetable_columns[TimetableColumn::STUDENTS_ENROLLED].text.to_i
            # Should be able to do save now as we have all info
            class_group = save_class(topic, class_component, class_number, students_enrolled >= class_size)
            class_timetable = timetable_columns[TimetableColumn::CLASS_SCHEDULE].search(".ClassMeetingTimetable")
            class_timetable.children.select {|row| !row.text?}.each_with_index do |row|
              case row["class"]
              when "DataTableHeaderRow"
                # nop
              else
                # Assume actual timetable data for other rows
                columns = row.children.select {|column| !column.text?}
                start_date = Date.parse(columns[ClassScheduleColumn::START_DATE].text.strip) rescue nil
                end_date = Date.parse(columns[ClassScheduleColumn::END_DATE].text.strip) rescue nil
                day_of_week = Date.parse(columns[ClassScheduleColumn::DAY].text.strip).strftime('%u') rescue nil
                start_time = Time.parse(columns[ClassScheduleColumn::START_TIME].text.strip) - Time.now.at_beginning_of_day rescue nil
                end_time = Time.parse(columns[ClassScheduleColumn::END_TIME].text.strip) - Time.now.at_beginning_of_day rescue nil
                #@logger.debug "Start Date: #{start_date}, End Date: #{end_date}, Day of Week: #{day_of_week}, Start Time: #{start_time}, End Time: #{end_time}}"
                save_activity(class_group, start_date, end_date, day_of_week, start_time, end_time)
              end
            end
          else
            @logger.error "Unknown row: #{row.inspect}"
          end
        end
      end
    end
  end
end

def save_topic name, option_name, campus, subject_area, topic_number, year, study_period
        # Note no stream support as different options should always be on different campuses,
        # and we don't want to suggest people timetables across campuses
        topic = Topic.where(
          :name => name + " (#{option_name} - #{campus})",
          :subject_area => subject_area,
          :topic_number => topic_number,
          :year => year,
          :semester => study_period,
          :institution => Institution.uni_sa
      ).first_or_initialize
      verb = topic.new_record? ? 'Saved' : 'Updated'
      topic.save
      @logger.debug '%s topic %s (%s %s) (%s)' % [verb, topic.code, topic.year, topic.semester, topic.name]
      return topic
end

def save_activity class_group, first_day, last_day, day_of_week, time_starts_at, time_ends_at
  class_session = Activity.where(
    :class_group => class_group,
    :first_day => first_day,
    :last_day => last_day,
    :day_of_week => day_of_week,
    :time_starts_at => time_starts_at,
    :time_ends_at => time_ends_at
  ).first_or_initialize
  verb = class_session.new_record? ? 'Saved' : 'Updated'
  class_session.save
  #@logger.debug '%s class session %s' % [verb, class_session.class_group]
end

def save_class topic, component, class_id, class_full
  class_type = ClassType.where(:topic => topic, :name => component).first_or_create
  class_group = ClassGroup.where(:class_type => class_type, :group_number => class_id).first_or_initialize
  # class_group.note = notes
  verb = class_group.new_record? ? 'Saved' : 'Updated'
  class_group.full = class_full
  class_group.save
  @logger.debug '%s class group %s (Is full?: %s)' % [verb, class_group.group_number, class_group.full]
  return class_group
end

module ClassScheduleColumn
  START_DATE = 0
  END_DATE = 1
  DAY = 2
  START_TIME = 3
  END_TIME = 4
  ROOM = 5
  INSTRUCTORS = 6
end

module TimetableColumn
  CAMPUS = 0
  ATTENDANCE = 1
  COMPONENT = 2
  CLASS_NUMBER = 3
  CLASS_SIZE = 4
  STUDENTS_ENROLLED = 5
  NOTES = 6
  CLASS_SCHEDULE = 7
end
