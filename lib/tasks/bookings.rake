namespace :bookings do
  desc "Update room bookings from the Flinders website"

  task :update => :environment do
    desc "Update"

    scrape
  end

  private
    agent = nil
    def scrape
      @agent = Mechanize.new
      page = @agent.get("http://stusyswww.flinders.edu.au/roombook.taf")

      scrape_bookings page
    end

    def scrape_bookings (page)
      form = page.form_with(:action=>/roombook\.taf/)

      buildingWidget = form.field_with(:name=>'bldg')

      buildingWidget.options.each do |code|
        building = Building.where(:code => code.value).first
        building ||= Building.create(:code => code.value, :name => code.text.split(/(.+) \((.+)\)/).second)

        buildingWidget.value = code
        buildingPage = form.submit

        scrape_bookings_building building, buildingPage
      end
    end

    def scrape_bookings_building (building, page)
      p building.name

      rooms = page/'#container_num_1 table tr'
      rooms.each do |roomRow|
        number = roomRow.search("a").first

        if number == nil then
          next
        end

        code = number.text.strip          
        if code == 'ALL' then
          next
        end

        desc = (roomRow/"td:last").text.strip.split(/(.+) \((.+)\)/)
        name = desc[1]
        capacity = desc[2]


        room = Room.where(:code => code).first
        room ||= Room.create(:code => code, :name => name, :capacity => capacity, :building => building)

        roomPage = @agent.get(number['href'])

        scrape_bookings_room room, roomPage
      end
    end

    NewBooking = Struct.new(:desc, :starts, :ends, :element)
    def scrape_bookings_room (room, page)
      timetable = page/'table.flincontenttable1'

      dates = []
      (timetable/'tr:first td:not(:first)').each do |dateCell|
        dates.push(Date.parse(dateCell.children.last.text))
      end

      periods = []
      (timetable/'tr:not(:first) td:first').each do |timeCell|
        periods.push(timeCell.text.gsub("noon", "pm").gsub("midnight", "am"))
      end


      bookings = []
      for i in 0..(dates.size-1) do
        # TODO: Fix bug which will cause dates after current year end to wrap back to start of year (Because Flinders' site doesn't include year for each date)
        # TODO: Add timestamp support
        day_start = Time.parse(dates[i].to_s + " " + periods.first)
        day_end = Time.parse(dates[i].to_s + " " + periods.last) + 1.hour

        (timetable/('tr:not(:first) td:nth-child(' + (i + 2).to_s + ')')).each_with_index do |booking, j|
          period_start = Time.parse(dates[i].to_s + " " + periods[j])
          period_end = Time.parse(dates[i].to_s + " " + periods[j]) + 1.hour

          desc = booking.text.gsub(/\u00a0/, ' ').strip
 
          if bookings.last != nil and bookings.last.desc == desc and bookings.last.ends == period_start then
            bookings.last.ends = period_end
          else
            bookings.push(NewBooking.new(desc, period_start, period_end, booking))
          end
        end
      end

      week_start = Time.parse(dates.first.to_s)
      week_end = week_start + 7.days

      RoomBooking.where(
        :room_id => room.id,
        :start => week_start .. week_end
        ).delete_all

      bookings.each do |scrapedBooking|
        if scrapedBooking.desc.empty? then
          next
        end

        booked_for = ""

        (scrapedBooking.element/'a').each do |link|
          if !booked_for.empty? then
            booked_for += "/"
          end
          booked_for += link.text
        end

        activity = scrapedBooking.element.children[2].text.gsub(/\u00a0/, ' ').strip

        booking = RoomBooking.new()
        booking.cancelled = false
        booking.room_id = room.id
        booking.start = scrapedBooking.starts
        booking.end = scrapedBooking.ends
        booking.booked_for = booked_for
        booking.description = activity

        booking.save
      end
    end
end
