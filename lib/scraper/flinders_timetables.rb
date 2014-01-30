module Scraper
  module FlindersTimetables

    def get_timetable_form page
      page.form_with(:action => /timetable\.taf/)
    end

    def get_next_page_form page
      forms = page.forms_with(:action => /timetable\.taf/)

      forms.each do |form|
        if form.button.value.match(/^Next [0-9]+ Matches/i) then
          return form
        end
      end

      return nil
    end

    def scrape_timetables_from_url url, year, limit_subject_area
      page = @agent.get url
      form = get_timetable_form page

      subject_area_widget = form.field_with(:name => 'subj')

      form.field_with(:name => 'year').value = year

      subject_area_widget.options.from(1).each do |entry|
        subject_code = entry.value
        name = entry.text.split(/^(.+) \((.+)\)/).second

        if !limit_subject_area.nil? and subject_code != limit_subject_area
          next
        end

        subject_area_widget.value = entry
        page = form.submit

        scrape_topics_on_page page
        while pagination_form = get_next_page_form(page) do

          begin
            page = pagination_form.submit
            scrape_topics_on_page page
          rescue => error
            begin
              page = pagination_form.submit
              scrape_topics_on_page page
            rescue => error_two
              puts "Failed to scrape %s" % name
            end
          end


          begin
            page = pagination_form.submit
            scrape_topics_on_page page
          rescue => error
            puts "Error #{$!} while importing %s" % name
            puts error.backtrace
          end
        end

      end
    end

    def scrape_topics_on_page page
      topic_links = page/'article[role="main"] a'

      topic_links.each do |topic_link|
        if topic_link['href'].match(/^topic.taf/).nil?
          next
        end

        begin
          url = topic_link['href'] + "&aims=Y&fees=Y"
          scrape_topic_page_from_url url
        rescue => error
          puts "Error #{$!} while importing %s" % topic_link['href']
          puts error.backtrace
        end
      end
    end

    def scrape_topic_page_from_url url
      page = @agent.get(url)

      topic_full_name = (page/"div.container h2:first").text.squish
      topic_title_meta = /^(?<Subject Area>[a-z]+)(?<Topic Number>[0-9]+[a-z]*) (?<Name>.*)$/i.match topic_full_name

      topic_meta_table_rows = page/"div.container > table.FlindersTable1 > tr"

      topic_meta = Hash.new

      topic_meta["Subject Area"] = topic_title_meta["Subject Area"]
      topic_meta["Topic Number"] = topic_title_meta["Topic Number"]
      topic_meta["Name"] = topic_title_meta["Name"]

      topic_meta["Coordinator"] = (page/"div.container h2:first").first.next_sibling.next_sibling.text.strip

      topic_meta_table_rows.each do |table_row|
        label = (table_row/"td:first").text.squish
        value = (table_row/"td:last").text.squish

        topic_meta[label] = value
      end

      # Each topic may be taught in multiple semesters, which are on the same page for some reason
      picks = []
      (page/"input.picklist").each do |pick|
        picks.append("#" + pick.attr('value'))
      end

      picks.each do |pick|
        meta = topic_meta.deep_dup

        meta_table = (page/(pick + " table:first"))
        meta_table_headings = meta_table/"tr:first td"
        meta_table_values = meta_table/"tr:last td"

        meta_table_headings.length.times do |x|
          heading = meta_table_headings[x].text.squish
          value = meta_table_values[x].text.squish

          meta[heading] = value
        end

        topic = Topic.where(
            :subject_area => topic_title_meta["Subject Area"],
            :topic_number => topic_title_meta["Topic Number"],
            :year => meta["Year"],
            :semester => meta["Sem"],
            :institution => Institution.flinders
        ).first_or_initialize

        topic.name = meta["Name"]
        topic.units = meta["Units"]
        topic.coordinator = meta["Coordinator"]
        topic.description = meta["Topic Description"]
        topic.learning_outcomes = meta["Expected Learning Outcomes"]
        topic.assumed_knowledge = meta["Assumed Knowledge"]
        topic.assessment = meta["Assessment"]
        topic.class_contact = meta["Class Contact"]
        topic.enrolment_opens = meta["First day to enrol"]
        topic.enrolment_closes = meta["Last day to enrol"]

        # Wrap up our changes to the topic here
        topic.save

        # Now create/update all child objects
        process_timetable page/(pick + " > div > table:first"), topic

        verb = topic.new_record? ? "Saving" : "Updating"
        puts "%s topic %s (%s %s) (%s)" % [verb, topic.code, topic.year, topic.semester, topic.name]
      end
    end

    def process_timetable timetable, topic
      rows = timetable/"tr"

      class_type = nil
      class_group = nil

      rows.each do |row|
        cells = row/"td"

        # Create new ClassType
        if cells.length == 2
          class_type = ClassType.where(
              :topic => topic,
              :name => cells[0].text.squish
          ).first_or_initialize

          class_type.note = cells[1].text.squish
          class_type.save
        else
          # Create new ClassGroup
          if cells.length == 6
            class_group = ClassGroup.where(
                :class_type => class_type,
                :group_number => (cells[0].text.scan /\(([0-9]+)\)/)[0][0]
            ).first_or_initialize
            Activity.where(:class_group => class_group).delete_all

            class_group.note = cells[5].text

            full = !(cells[5].text.scan /FULL/).empty?
            class_group.full = full && Time.now > topic.enrolment_opens

            cells.shift
          end

          # Create new ClassSession
          date_range = cells[0].text.split("-")
          time_range = cells[2].text.split("-")

          room_details = cells[3].text.squish.split(': ')

          if room_details.length == 2
            room = Room.joins(:building).where("(buildings.name = ? OR buildings.code = ?) AND rooms.code = ?", room_details[0].to_s, room_details[0].to_s, room_details[1].to_s).first
          end

          time_starts_at = Time.parse(time_range[0].strip) - Time.now.at_beginning_of_day
          time_ends_at = Time.parse(time_range[1].strip) - Time.now.at_beginning_of_day

          # Get the immediate previous activity for this topic if it exists so we can just join them
          class_session = Activity.where(
              :class_group => class_group,
              :first_day => Date.parse(date_range[0].strip),
              :last_day => Date.parse(date_range[1].strip),
              :day_of_week => Date.parse(cells[1].text.strip).strftime('%u'),
              :time_ends_at => [time_starts_at, time_starts_at - 10.minutes],
              :room_id => room.nil? ? nil : room.id
          ).first

          # Otherwise create a new one
          class_session = class_session || Activity.new(
              :class_group => class_group,
              :first_day => Date.parse(date_range[0].strip),
              :last_day => Date.parse(date_range[1].strip),
              :day_of_week => Date.parse(cells[1].text.strip).strftime('%u'),
              :time_starts_at => time_starts_at,
              :room_id => room.nil? ? nil : room.id
          )

          if !class_session.new_record?
            puts "Joining adjacent class activities for %s %s" % [topic.name, class_type.name]
          end

          class_session.time_ends_at = time_ends_at

          class_session.save
        end
      end
    end

  end
end
