module Scraper
  module UnisaTimetables
    def getMyEnrolment
      page = clean_asp @agent.get 'https://my.unisa.edu.au/Student/myEnrolment/myEnrolment/EnrolmentSummary.aspx'
      return page
    end

    # Return a list of StudyPeriods available on myEnrolment
    StudyPeriod = Struct.new(:id, :year, :year_end, :period)

    def get_study_periods
      form = getMyEnrolment().forms.first

      study_periods = []

      # Extract study periods from <option>s
      form.field_with(:id => 'dropStudyPeriod').options.each do |option|
        details = option.text.scan(/Study Period ([0-9])+ - ([0-9]+)(?:\/([0-9]+))?/)[0]
        study_period = StudyPeriod.new(option.value.to_i, details[1].to_i, details[2].to_i, details[0].to_i)

        if (study_period.year_end == 0)
          study_period.year_end = study_period.year
        end

        study_periods << study_period
      end

      return study_periods
    end

    def get_courses_page study_period
      # Load the study period page and set it to the correct study period (Click 'get information for study period')
      sp_form = getMyEnrolment().forms.first
      sp_form.field_with(:id => 'dropStudyPeriod').value = study_period.id
      sp_change_button = sp_form.button_with(:value => 'Get information for the selected Study Period')
      sp_page = clean_asp sp_form.click_button(sp_change_button)

      # Load the page again and click the ''
      sp_form = sp_page.forms.first

      sp_change_button = sp_form.button_with(:value => 'Add course')

      if sp_change_button == nil
        return nil
      end

      return clean_asp sp_form.click_button(sp_change_button)
    end

    SubjectArea = Struct.new(:code, :name)

    def scrape_study_period study_period, subject_area_limit
      courses_page = get_courses_page(study_period)

      if (courses_page == nil)
        @logger.warn 'Could not scrape study period %d. Maybe it\'s passed?' % study_period.period
        return
      else
        @logger.info 'Scraping study period %d SP%d' % [study_period.year, study_period.period]
      end

      courses_form = courses_page.forms.first
      subject_area_field = courses_form.field_with(:id => 'dropSubjectArea')
      cat_num_field = courses_form.field_with(:id => 'txtCatalogueNumber')
      search_button = courses_form.button_with(:value => 'Search')


      subject_area_field.options.from(1).each do |subject_area|
        if !subject_area_limit.nil? and subject_area_limit != subject_area.value
          next
        end
        @logger.info 'Scraping topic area: %s %s SP%s' % [subject_area.text, study_period.year, study_period.period]
        subject_area_field.value = subject_area
        cat_num_field.value = ''
        topic_list_page = clean_asp courses_form.click_button(search_button)

        topic_list = topic_list_page/'table.ClassTimeTable#grdvwCourse tr:not(:first-child)'

        if topic_list.length == 0 and !(topic_list_page/'.OptionNote').nil?
          scrape_topic_page study_period, topic_list_page
        else
          topic_list.each do |topic|
            catNumber = topic.css('td')[2].text.to_i
            cat_num_field.value = catNumber

            topic_page = clean_asp courses_form.click_button(search_button)

            begin
              scrape_topic_page study_period, topic_page
            rescue
              @logger.error "#{$!} when scraping %s %s" % [subject_area.text, catNumber]
            end
          end
        end
      end
    end

    def scrape_topic_page(study_period, topic_page)
      form = topic_page.forms.first
      option_buttons = form.buttons_with(:value => /Option [0-9]+/)
      option_names = (topic_page/'.OptionNote').map { |x| x.text }

      if option_buttons.length == 1
        # If there's only one option, don't click any buttons to show options (as we'll actually toggle and hide it)
        scrape_topic_page_option topic_page, study_period, '', option_names.first

      else
        # Otherwise, iterate over every option and click its 'show' button and scrape it
        option_buttons.each_with_index do |option_button, index|
          campus = option_names[index]
          option_page = clean_asp form.click_button(option_button)

          # Add the option number and campus
          name_suffix = ' (%s - %s)' % [option_button.value, campus]

          scrape_topic_page_option option_page, study_period, name_suffix, campus
        end
      end
    end

    def scrape_topic_page_option(option_page, study_period, name_suffix, campus)
      if campus == 'External'
        @logger.info 'Skipping External campus'
        return
      end

      # We have a Topic object for each option (e.g. "Digital Electronics (City West)")
      topic_heading = option_page.search('#pnlCourseHeaderArea h3').text.squish
      name, subject_area, cat_num, graduate_level = topic_heading.scan(/(.*) - ([A-Z]*) ([0-9]+) - (.*)/)[0]

      topic = Topic.where(
          :name => name + name_suffix,
          :subject_area => subject_area,
          :topic_number => cat_num,
          :year => study_period.year,
          :semester => 'SP%d' % study_period.period,
          :institution => Institution.uni_sa
      ).first_or_initialize

      topic.save
      verb = topic.new_record? ? 'Saved' : 'Updated'
      @logger.debug '%s topic %s (%s %s) (%s)' % [verb, topic.code, topic.year, topic.semester, topic.name]

      # Scrape timetables for option
      scrape_topic_page_timetable topic, option_page
    end

    def scrape_topic_page_timetable(topic, option_page)
      @logger.info 'Scraping timetable for %s' % topic.name
      class_timetables = option_page/'#pnlOptionData > div:nth-child(even) > table'

      class_timetables.each do |tt|
        # Get every row for the timetable, except for the header
        rows = tt.xpath('tr')
        rows.shift()

        rows.each_with_index do |row, index|
          cells = row.xpath('td')

          component = cells[2].text.squish
          class_id = index
          class_size = cells[4].text.squish
          class_enrolled = cells[5].text.squish
          full = class_size == class_enrolled
          notes = cells[6].text.squish
          schedule = cells[7]

          class_type = ClassType.where(:topic => topic, :name => component).first_or_create

          class_group = ClassGroup.where(:class_type => class_type, :group_number => class_id).first_or_create
          # class_group.note = notes
          class_group.full = full
          class_group.save


          sched_rows = schedule.css('tr:not(:first-child)')

          begin
            sched_rows.each do |sched_row|
              sched_cells = sched_row.xpath('td')

              first_day = Date.parse(sched_cells[0].text.strip) rescue nil
              last_day = Date.parse(sched_cells[1].text.strip) rescue nil
              day_of_week = Date.parse(sched_cells[2].text.strip).strftime('%u') rescue nil
              time_starts_at = Time.parse(sched_cells[3].text.strip) - Time.now.at_beginning_of_day rescue nil
              time_ends_at = Time.parse(sched_cells[4].text.strip) - Time.now.at_beginning_of_day rescue nil

              class_session = Activity.where(
                  :class_group => class_group,
                  :first_day => first_day,
                  :last_day => last_day,
                  :day_of_week => day_of_week,
                  :time_starts_at => time_starts_at,
                  :time_ends_at => time_ends_at
              ).first_or_create
            end
          rescue =>error
            @logger.error "#{$!} when scraping %s" % topic.code
            @logger.error error.backtrace
          end
        end
      end
    end


    # Replace every id on a page with just what's followed by the final underscore and before the first
    # Could I use constants? Probably, but that would mean concatenating CSS selectors which would be weird
    def clean_asp page
      page.root.traverse do |node|
        if node['id'] != nil
          node['id'] = node['id'].scan(/(?:.*_)?([^_#]+)(?:#.*)?/)[0][0]
        end

        if node['value'] != nil
          node['value'] = node['value'].strip()
        end
      end

      return page
    end
  end
end
