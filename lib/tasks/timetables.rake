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

        scrape_topic_page @agent.get(topic_link['href'] + "&aims=Y&fees=Y")
      end

    end

    def scrape_topic_page page
      topic_full_name = (page/"div.container h2:first").text.squish
      topic_title_meta = /^(?<subject_area>[a-z]+)(?<topic_code>[0-9]+[a-z]*) (?<topic_name>.*)$/i.match topic_full_name

      meta_table_rows = page/"div.container > table.FlindersTable1 > tr"

      meta_table_rows.each do |table_row|
        label = (table_row/"td:first").text.squish

        p label
      end
    end

end
