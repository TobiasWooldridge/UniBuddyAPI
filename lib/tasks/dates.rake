namespace :dates do
  desc "Scrape dates from Flinders website"
  task :term => :environment do
    desc "Pull term dates"

    @agent = Mechanize.new

    page = @agent.get("http://www.flinders.edu.au/current-students/dates/semester-dates.cfm")

    rows = page.search('#container_num_1 table:first tr');
    years = []

    rows.first.search('td').each do |yearBox|
      years.append(yearBox.text)
    end

    years.shift

    rows.shift
    rows.shift

    semester = ""
    rows.each do |row|
      label = row.search("td:first").text
      contentBoxes = row.search("td + td")

      if /(Summer|Semester [12])/i.match(label)
        semester = label.titlecase
      else
        if /^[0-9\s\*]/.match(label)
          label = "Week %s" % label
        end



        contentBoxes.each_with_index do |c, index|
          contentText = c.text.gsub(/[[:space:]]/, ' ').strip

          if contentText == ""
            next
          end

          year = years[index]
          week_start = Time.parse("%s %s" % [year, contentText])
          week_end = week_start + 1.week - 1.second


          TermDates.where("? BETWEEN starts_at AND ends_at", week_start).delete_all

          termDate = TermDates.new
          termDate.starts_at = week_start
          termDate.ends_at = week_end
          termDate.semester = semester
          termDate.week = label
          termDate.institution = Institution.flinders


          termDate.save
        end
      end
    end

  end
  private
    agent = nil
end
