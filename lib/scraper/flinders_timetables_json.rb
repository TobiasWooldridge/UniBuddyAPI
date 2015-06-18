module Scraper
  module FlindersTimetables

  	def scrape_timetables base_url, year, subject_area

  		topiclisturl = "%s/topic/getTopicList?format=json&tdtopicsubject=%s&tdtopicnumber=&tdtopicfulltitlelower=&tdyear=%s" % [base_url, subject_area, year]

  		topics_found = 0
  		total_topics = 0
  		total_class_types = 0
  		total_class_groups = 0
  		total_class_sessions = 0

  		puts "getting topics from %s" % topiclisturl

  		results = JSON.parse @agent.get(topiclisturl).body

  		if results['SUCCESS'] == 1
  			topics = results['TOPICLIST']['TOPICS']

  			puts "Found %i topics" % topics.length
  			topics_found = topics.length

  			topics.each do |topic|
  				saved_topics, class_types, class_groups, class_sessions = scrape_topic base_url, topic, year
  				total_topics += saved_topics
  				total_class_types += class_types
  				total_class_groups += class_groups
  				total_class_sessions += class_sessions
  			end

  		end
  		return topics_found, total_topics, total_class_types, total_class_groups, total_class_sessions
  	end

  	def scrape_topic base_url, topic, year
  		topicDetailsBaseUrl = "%s/topic/getTopicDetails?format=json&test=&tdyear=%s&tdtopicsubject=%s&tdtopicnumber=%s" % [base_url, year, topic['TDTOPICCODE'][0,4], topic['TDTOPICCODE'][4,5]]

  		#puts "getting topic details from %s" % topicDetailsBaseUrl
  		results = JSON.parse @agent.get(topicDetailsBaseUrl).body
  		total_topics = 0
  		total_class_types = 0
  		total_class_groups = 0
  		total_class_sessions = 0

  		if results['SUCCESS'] == 1
  			#puts "found details for %s" % results['TOPIC'][0]['TDTOPICFULLTITLE']
  			#get topic information

  			topic_meta = {}

  			topic_meta['Subject Area'] = results['TOPIC'][0]['TDTOPICSUBJECT']
  			if results['TOPIC'][0]['TDTOPICNUMBER'].is_a? Numeric
  				topic_meta["Topic Number"] = "%04d" % results['TOPIC'][0]['TDTOPICNUMBER'].to_i
  			else
				topic_meta["Topic Number"] = results['TOPIC'][0]['TDTOPICNUMBER']
  			end
  			topic_meta["Name"] = results['TOPIC'][0]['TDTOPICFULLTITLE']
  			topic_meta["Coordinator"] = results['TOPIC'][0]['TDCOORDINATOR']
  			topic_meta['Special Arrangements'] = results['TOPIC'][0]['TDSPECIALARRANGEMENTS']

  			topic_meta['Year'] = results['TOPIC'][0]['TDYEAR']
  			topic_meta['Units'] = results['TOPIC'][0]['TDTOPICUNITS']
  			topic_meta['Class Contact'] = results['TOPIC'][0]['TDCLASSCONTACT']
  			topic_meta['Prerequisites'] = results['TOPIC'][0]['TDPREREQUISITES']
  			topic_meta['Enrolment not permitted'] = results['TOPIC'][0]['TDANTIREQUISITES']
  			topic_meta['Corequisites'] = results['TOPIC'][0]['TDCOREQUISITES']
  			topic_meta['Other requirements'] = results['TOPIC'][0]['TDOTHERREQUIREMENTS']
  			topic_meta['Assumed Knowledge'] = results['TOPIC'][0]['TDASSUMEDKNOWLEDGE']
  			topic_meta['Course Context'] = results['TOPIC'][0]['TDCOURSECONTEXT']
  			topic_meta['Assessment'] = results['TOPIC'][0]['TDASSESSMENT']
  			topic_meta['Topic Description'] = results['TOPIC'][0]['TDDESCRIPTION']
  			topic_meta['Expected Learning Outcomes'] = results['TOPIC'][0]['TDAIMS']

  			topicAvailablitiesBaseUrl = "%s/timetable/getAvailabilities?format=json&avyear=%s&avtopicsubject=%s&avtopicnumberexact=%s" % [base_url, year,topic['TDTOPICCODE'][0,4], topic['TDTOPICCODE'][4,5]]

  			results = JSON.parse @agent.get(topicAvailablitiesBaseUrl).body
  			if results['SUCCESS'] == 1
  				class_types, class_groups, class_sessions = process_availabilities base_url, year, topic_meta, results['AVAILABILITYLIST']['AVAILABILITIES']
  				total_class_types += class_types
  				total_class_groups += class_groups
  				total_class_sessions += class_sessions
  				total_topics += 1
  			elsif results['SUCCESS'] == 2
  				puts "Topic not available this year: %s" % topic_meta["Name"]
  			elsif results['SUCCESS'] == 0
  				puts results['EXCEPTION']
  			else
  				puts "Parse error looking for timetables for %s" % topic_meta["Name"]
  			end
  				

  		elsif results['SUCCESS'] == 2
  			puts "Topic %s not available this year" % topic['TDTOPICCODE']
  		elsif results['SUCCESS'] == 0
  			puts results['EXCEPTION']
  		else
  			puts "parse error for topic %s" % topic['TDTOPICCODE']
  		end
  		return total_topics, total_class_types, total_class_groups, total_class_sessions
  	end

  	def process_availabilities base_url, year, topic_meta, availabilities
  		total_class_types = 0
  		total_class_groups = 0
  		total_class_sessions = 0
  		availabilities.each do |availability|
			meta = topic_meta.deep_dup

			meta['Topic'] = availability['AVTOPICCODE']
			meta['Title'] = availability['AVTOPICTITLE']
			meta['Units'] = availability['AVTOPICUNITS']
			meta['Sem'] = availability['AVSEMESTER']
			meta['Location'] = availability['AVLOCATIONDESCRIPTION']
			meta['Avail No'] = availability['AVNUMBER']
			meta['Mode'] = availability['AVATTENDMODE']
			meta['First day to enrol'] = availability['AVENROLSTARTDATEDISPLAY']
			meta['Last day to enrol'] = availability['AVENROLENDDATEDISPLAY']
			meta['Census date'] = availability['AVCENSUSDATEDISPLAY']
			meta['Last day to withdraw without failure'] = availability['AVWITHDRAWNOFAILDATEDISPLAY']

			subscriptMatch = /(?<subscript>Held .+$)/.match(meta["Title"])

			subscript = nil
			if subscriptMatch
			  subscript = subscriptMatch[:subscript]
			end

			topic = Topic.where(
			    :subject_area => meta["Subject Area"],
			    :topic_number => meta["Topic Number"],
			    :year => meta["Year"],
			    :semester => meta["Sem"],
			    :institution => Institution.flinders,
			    :subscript => nil,
			    :location => meta["Location"]
			).first || Topic.where(
			    :subject_area => meta["Subject Area"],
			    :topic_number => meta["Topic Number"],
			    :year => meta["Year"],
			    :semester => meta["Sem"],
			    :institution => Institution.flinders,
			    :subscript => subscript,
			    :location => meta["Location"]
			).first_or_initialize

			topic.name = meta["Name"]
			topic.units = meta["Units"]
			topic.location = meta["Location"]
			topic.subscript = subscript
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

			class_types, class_groups, class_sessions = save_timetable base_url, year, availability, topic
			total_class_types += class_types
			total_class_groups += class_groups
			total_class_sessions += class_sessions

			verb = topic.new_record? ? "Saving" : "Updating"
			puts "%s topic %s (%s %s %s) (%s)" % [verb, topic.code, topic.year, topic.semester, topic.location, topic.name]
  		end
  		return total_class_types, total_class_groups, total_class_sessions
  	end

  	def save_timetable base_url, year, availability, topic
  		timetableBaseUrl = "%s/timetable/getTimetable?format=json&test=&avyear=%s&cpkeynumber=%i" % [base_url, year, availability['AVKEYNUMBER']]

  		classes = JSON.parse @agent.get(timetableBaseUrl).body

  		class_types = 0;
  		class_groups = 0;
  		class_sessions = 0;

  		if classes['SUCCESS'] == 1
  			#puts "found %s classes for %s" % [classes['CLASSLIST']['CLASSES'].length,  topic.name]
  			
  			groupedClasses = classes['CLASSLIST']['CLASSES'].group_by {|clazz| clazz['CPACTIVITYNAMENOSPACES']}

  			groupedClasses.keys.each do |className|
  				class_type = ClassType.where(
  				    :topic => topic,
  				    :name => groupedClasses[className][0]['ACTIVITY_NAME']
  				).first_or_initialize

  				class_type.note = groupedClasses[className][0]['CPACTIVITYCOMMENT']
  				class_type.save
  				class_types += 1

  				groupedClasses[className] = groupedClasses[className].group_by {|clazz| clazz['CPCLASSNUMBER']}
  				groupedClasses[className].keys.each do |bracket|
  					class_group = ClassGroup.where(
  					    :class_type => class_type,
  					    :group_number => bracket
  					).first_or_initialize
  					Activity.where(:class_group => class_group).delete_all

  					class_group.note = groupedClasses[className][bracket][0]['CPBOOKINGCOMMENT']

  					if groupedClasses[className][bracket][0]['CPCLASSSTREAM'].to_s.length > 0
  					  # Create new Stream
  					  streamName = groupedClasses[className][bracket][0]['CPCLASSSTREAM']

  					  stream = Stream.where(
  					      :topic => topic,
  					      :name => streamName
  					  ).first_or_create

  					  class_group.stream = stream
  					else
  					  class_group.stream = nil
  					end

  					class_group.full = groupedClasses[className][bracket][0]['CPCLASSPLACES'] == "FULL"

  					class_group.save
  					class_groups += 1
  					#add class sessions
  					groupedClasses[className][bracket].each do |session|
  						if session['CPCLASSNUMBER'] == ""
  							next
  						end
	  					time_starts_at = Time.parse(session['CPBOOKINGSTARTTIME']) - Time.now.at_beginning_of_day
	  					time_ends_at = Time.parse(session['CPBOOKINGENDTIME']) - Time.now.at_beginning_of_day

	  					first_day = Date.parse(session['CPBOOKINGSTARTDATE'])
	  					last_day = Date.parse(session['BOOKING_END_DATE'])

	  					
						room = Room.joins(:building).where("(buildings.name = ? OR buildings.code = ?) AND rooms.code = ?", 
							session['BOOKING_BUILDING_NAME'].to_s, 
							session['BOOKING_BUILDING_ID'].to_s, 
							session['BOOKING_ROOM_ID'].to_s).first
						

	  					# Get the immediate previous activity for this topic if it exists so we can just join them
	  					class_session = Activity.where(
	  					    :class_group => class_group,
	  					    :first_day => first_day,
	  					    :last_day => last_day,
	  					    :day_of_week => Date.parse(session['BOOKING_DAY']).strftime('%u'),
	  					    :time_ends_at => [time_starts_at, time_starts_at - 10.minutes],
	  					    :room_id => room.nil? ? nil : room.id
	  					).first

	  					# Otherwise create a new one
	  					class_session = class_session || Activity.new(
	  					    :class_group => class_group,
	  					    :first_day => first_day,
	  					    :last_day => last_day,
	  					    :day_of_week => Date.parse(session['BOOKING_DAY']).strftime('%u'),
	  					    :time_starts_at => time_starts_at,
	  					    :room_id => room.nil? ? nil : room.id
	  					)

	  					if !class_session.new_record?
	  					  puts "Joining adjacent class activities for %s %s" % [topic.name, class_type.name]
	  					end

	  					class_session.time_ends_at = time_ends_at

	  					if class_session.new_record?
	  						class_sessions += 1
	  					end
	  					
	  					class_session.save
	  				end
  				end
  			end
  			
  		elsif classes['SUCCESS'] == 2
  			puts timetableBaseUrl
  			puts "Expected error fetching timetale??? for topic %s" % topic.name
  		elsif classes['SUCCESS'] == 0
  			puts results['EXCEPTION']
  		else
  			puts "error pasing timetable results for topic %s" % topic.name
  		end

  		return class_types, class_groups, class_sessions

  	end

  end
end
