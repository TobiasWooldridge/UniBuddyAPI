namespace :timetables do
  desc "Update class timetables from the Flinders website"

  task :update => :environment do
    desc "Update"

    @agent = Mechanize.new

    scrape_timetables_from_url "http://stusyswww.flinders.edu.au/timetable.taf"
  end

  private
    agent = nil

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

      nil
    end

    def scrape_timetables_from_url url
      page = @agent.get url
      form = get_timetable_form page

      subject_area_widget = form.field_with(:name=>'subj')

      subject_area_widget.options.from(1).each do |entry|
        subject_code = entry.value
        name = entry.text.split(/^(.+) \((.+)\)/).second

        subject_area_widget.value = entry
        page = form.submit

        scrape_topics_on_page page
        while pagination_form = get_next_page_form(page) do
          page = pagination_form.submit

          scrape_topics_on_page page
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
          scrape_topic_page @agent.get(topic_link['href'] + "&aims=Y&fees=Y")
        rescue
          puts "Error #{$!} while importing %s" % topic_link['href']
        end
      end

    end

    def scrape_topic_page page
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

        topic = Topic.where(:subject_area => topic_title_meta["Subject Area"], :topic_number => topic_title_meta["Topic Number"], :year => meta["Year"], :semester => meta["Sem"]).first

        topic ||= Topic.create(:subject_area => topic_title_meta["Subject Area"], :topic_number => topic_title_meta["Topic Number"], :year => meta["Year"], :semester => meta["Sem"])

        topic.name = meta["Name"]
        topic.units = meta["Units"]
        topic.coordinator = meta["Coordinator"]
        topic.description = meta["Topic Description"]
        # topic.aims = // TODO
        topic.learning_outcomes = meta["Expected Learning Outcomes"]
        topic.assumed_knowledge = meta["Assumed Knowledge"]
        topic.assessment = meta["Assessment"]      
        topic.class_contact = meta["Class Contact"]    
        topic.enrolment_opens = meta["First day to enrol"]
        topic.enrolment_closes = meta["Last day to enrol"]

        topic.save

        p "Saving topic %s (%s %s) (%s)" % [topic.code, topic.year, topic.semester, topic.name]
      end
    end
end
