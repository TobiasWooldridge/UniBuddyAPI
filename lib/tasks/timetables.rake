namespace :timetables do
  desc "Update class timetables from the Flinders website"

  task :update => :environment do
    desc "Update"

    @agent = Mechanize.new

    scrape_timetables
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

    def scrape_timetables
      page = @agent.get("http://stusyswww.flinders.edu.au/timetable.taf")
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

        p "Scraping %s" % topic_link.text

        scrape_topic topic_link['href']
      end

    end

    def scrape_topic
      # TODO: this function is important :<
    end

end
