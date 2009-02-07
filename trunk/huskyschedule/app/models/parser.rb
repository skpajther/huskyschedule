class Parser < ActiveRecord::Base
  
  def self.category_parser(url)
    uri = URI.parse("http://www.washington.edu/students/timeschd/WIN2009/chid.html")
    response = Net::HTTP.get_response(uri)
    contents = response.body.split("\n")
    i=0
    #variables to be filled
    quarter = Quarter::CURRENT
    year = 0
    category = ""
    course_number = 0
    dept_abbrev = ""
    course_title = ""
    course_description = ""
    credit_type = ""
    restricted = false
    section = ""
    sln = 0
    creditAmount = 0
    message = ""
    active_lecture = nil
    #end variables to be filled
    
    #get category from <TITLE> tags
    while(i<contents.length)
      line = contents[i]
      matches = line.match(/^<TITLE>(.*)<\/TITLE>$/)
      if(!matches.nil?)
        category = matches[1]
        break
      else
        i+=1
      end
    end
    
    #get quarter, year from <h1> tags
    while(i<contents.length)
      line = contents[i]
      matches = line.match(/^<h1>([A-Za-z]+).*(\d\d\d\d).*<\/h1>$/)
      if(!matches.nil?)
         quarter = Quarter.quarter_constant(matches[1])
         year = matches[2].to_i
         break
      else
        i+=1
      end
    end
    
    #TODO: Course fees
    while(i<contents.length)
      line = contents[i]
      if(/^<br>$/i.match(line))
        #beginning a course
        i+=1
        while(i<contents.length)
          line = contents[i]
          matches = line.match(/NAME=([A-Za-z]+)([0-9]+)>/i) #<A NAME=academ198>
          if(!matches.nil?) #ready to process all lectures/quiz sections of a course
            dept_abbrev = matches[1].upcase
            course_number = matches[2].to_i
            course_title = get_course_title(line, course_number)
            course_description = get_course_description(line, course_number)
            credit_type = get_credit_type(line)
            while(i<contents.length) #ready to start gathering data about the lectures/sections
              line2 = contents[i]
              matches2 = line2.match(/SLN=(\d+)>/i)
              if(!matches2.nil?) #process this class's data
                sln = matches2[1].to_i
                section = get_section(line2, sln)
                c = nil
                lab_or_quiz = section.length > 1
                if(!lab_or_quiz) #lecture
                  c = Course.create(:deptabbrev=>dept_abbrev, :number=>course_number, :title=>course_title, :description=>course_description, :credit_type=>credit_type, :quarter_id=>quarter, :year=>year)
                  active_lecture = c
                elsif(/LB/.match(line2))
                  c = Lab.create(:parent_id=>active_lecture.id)
                else
                  c = QuizSection.create(:parent_id=>active_lecture.id)
                end
                c.sln = sln
                c.section = section
                i = process_course(c, i, contents, line2, lab_or_quiz)
                c.save()
              elsif(/^<br>$/i.match(line2) || /to be arranged/i.match(line2))
                break
              else
                i+=1 #continue advancing through the lines
              end
            end #finished processing a lecture, check for quiz sections
          elsif(/^<br>$/i.match(line))
            break
          else
            i+=1 #continue advancing through the lines
          end
        end #finished processing a course  
      elsif(!(line.match(/^<div id="footer"/i).nil?))
        return "breaking"
      else
        i+=1 #continue advancing through the lines
      end
    end #outer-most while loop
    return message
  end
  
  def self.process_course(c, i, contents, line, lab_or_quiz)
    if(/to be arranged/i.match(line))
      return i+1
    else
      if(!lab_or_quiz)
        assign_credit_amount(c, line, c.sln, c.section)
        c.restricted = get_restricted(line)
        #check_for_additional_credit_types(c, line) TODO: fix this
      end
      c.additional_info = get_additional_info(line)
      #check_for_additional_credit_types(c, line) do we want to do this for quiz sections?
      times = get_times(c.sln, c.section, line)
      building_id = get_building_id(line)
      building = Building.find_by_id(building_id)
      #c.building_id = get_building_id(line)
      if(c.building_id != -1)
        room = get_room(line, building.abbrev)
        c.teacher_id = get_teacher_id(room, line)
      else
        room = -1.to_s
      end
      c.rendezvous = [Rendezvous.new(:times=>times, :building_id=>building_id, :room=>room)]
      c.crnc = get_crnc(line)
      c.status = Course.get_status(line)
      assign_enrollment_ratio(c, line)
      #puts("Assigned enrollment ratio correctly for #{c.inspect}\n")
      if(c.description.nil?)
        c.description = ""
      end
      c.description += get_course_fee(line)
      #puts("assigned course fee correctly, description = #{c.description}\n\n")
      #notes
      i+=1
      notes = ""
      while(i < contents.size)
        line2 = contents[i]
        if(is_line_of_class_times(line2))
          process_line_of_class_times(c, line2)
        elsif(/^<\/td>/.match(line2))
          break
        else
          notes += line2.strip + " "
        end
        i+=1
      end
      c.notes = notes.strip
      #c.times = times
      return i
    end
  end
  
  def self.get_course_title(line, course_number)
    matches = line.match(/<a href=(.*#{course_number})>(.*)<\/A>/i)
    url = matches[1]
    uri = URI.parse("http://www.washington.edu#{url}")
    response = Net::HTTP.get_response(uri)
    contents = response.body.split("\n")
    i=0
    while(i<contents.length)
      line2 = contents[i]
      matches2 = line2.match(/#{course_number}\s?<\/A>\s+([^\(]+)\(/i)
      if(!matches2.nil?)
        return matches2[1].strip
      else
        i+=1
      end
    end
    return matches[2] #chasing the class title failed, use what was on timeschedule page
  end
  
  def self.get_course_description(line, course_number)
    matches = line.match(/<a href=(.*#{course_number})>(.*)<\/A>/i)
    url = matches[1]
    uri = URI.parse("http://www.washington.edu#{url}")
    response = Net::HTTP.get_response(uri)
    contents = response.body.split("\n")
    i=0
    while(i<contents.length)
      line2 = contents[i]
      matches2 = line2.match(/^<P><B><A NAME=.*#{course_number}.*>.*#{course_number}.*<\/A>.*<BR>(.*)$/i)
      if(!matches2.nil?)
        return matches2[1]
      else
        i+=1
      end
    end
    return "" #unable to find course description
  end
  
  def self.get_credit_type(line)
    matches = line.match(/<b>\((.*)\)<\/b>/i)
    if(!matches.nil?)
      return Course.get_credit_types(matches[1])
    else
      return [Course::CREDITTYPE_NOTLISTED]
    end
  end
  
  def self.get_restricted(line)
    return !(line.match(/^Restr/).nil?)
  end
  
  def self.get_section(line, sln)
    matches = line.match(/#{sln}.*>.*<\/A>\s(\S{1,2})/i)
    matches2 = line.match(/<\/A>\s\S{1,2}\s/)
    if(!matches.nil?)
       return matches[1]
    else
      return "error on line #{line}"
    end
  end
  
  def self.assign_credit_amount(c, line, sln, section)
    matches = line.match(/#{sln}.*>.*<\/A>\s+#{section}\s+([0-9-]+)/i)
    credits = matches[1]
    if(/-/.match(credits))
      split = credits.split(/-/)
      c.credits = split[0].to_i #lowest = most significant
      c.variable_credit = split[1].to_i #highest = variable
    else
      c.credits = credits.to_i
    end
  end
  
  MONDAY = Time.parse("Monday January 26, 2009")
  TUESDAY = Time.parse("Tuesday January 27, 2009")
  WEDNESDAY = Time.parse("Wednesday January 28, 2009")
  THURSDAY = Time.parse("Thursday January 29, 2009")
  FRIDAY = Time.parse("Friday January 30, 2009")
  
  def self.build_times_array(days_of_week, start_time_string, end_time_string)
    start_time_pm = false
    end_time_pm = false
    start_time = start_time_string.to_i #930
    start_hour = start_time/100 #9 /
    start_minutes = start_time%100 #30
    if(/P/.match(end_time_string))
      end_pm = true
      end_time_string = end_time_string.match(/([0-9]+)/)[1]
    end
    end_time = end_time_string.to_i #1020  
    end_hour = end_time/100 #10 /
    end_minutes = end_time%100 #20
    if(start_hour == 12)
      start_pm = true
      end_pm = true
    elsif(end_hour == 12)
      end_pm = true
      start_pm = false
    elsif(start_hour > end_hour) #11am - 1pm
      end_pm = true
      start_pm = false
    else #start_hour < end_hour
      if(end_pm) #was set above when a "P" was seen
        start_pm = true
      elsif(start_hour >= 7 && start_hour < 11) #between 7am and 10am
        end_pm = false
        start_pm = false
      else #1 <= start <= _____
        start_pm = true
        end_pm = true
      end  
    end
    start_time_string = start_hour.to_s + ":" + start_minutes.to_s + " " + ((start_pm)? "pm" : "am")
    end_time_string = end_hour.to_s + ":" + end_minutes.to_s + " " + ((end_pm)? "pm" : "am")
    times = []
    if(/M/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = MONDAY), Time.parse(end_time_string, now = MONDAY)])
    end
    if(/TW/.match(days_of_week) || /TTh/.match(days_of_week) || /TF/.match(days_of_week) || /T$/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = TUESDAY), Time.parse(end_time_string, now = TUESDAY)])
    end
    if(/W/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = WEDNESDAY), Time.parse(end_time_string, now = WEDNESDAY)])
    end
    if(/Th/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = THURSDAY), Time.parse(end_time_string, now = THURSDAY)])
    end
    if(/F/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = FRIDAY), Time.parse(end_time_string, now = FRIDAY)])
    end
    return times
  end
  
  def self.get_times(sln, section, line)
    matches = line.match(/#{sln}\s*<\/A>\s+#{section}\s+(\d?)\s+[QZLB]{0,2}\s+([A-Za-z]+)\s+([0-9]+)-([0-9P]+)\s+/i)
    if(!matches.nil?)
      days_of_week = matches[2] #"MTWThF"
      start_time_string = matches[3] #"930"
      end_time_string = matches[4] #"1020" or "1020P"
      return build_times_array(days_of_week, start_time_string, end_time_string)
    else
      return []
    end
  end
  
  def self.get_building_id(line)
    matches = line.match(/>([A-Z]{2,5})</)
    if(!matches.nil?)
      building_abbrev = matches[1]
      building = Building.find_by_abbrev(building_abbrev)
      if(building.nil?) #building is already in there
        building = Building.create(:abbrev => building_abbrev)
      end
       return building.id
    else
      return -1
    end  
  end
  
  def self.get_room(line, building_abbrev)
    return line.match(/>#{building_abbrev}<\/a>\s+([0-9A-Z]+)\s+/i)[1]
  end
  
  def self.get_teacher_id(room, line)
    id = 0
    if(/#{room}\s+\d+\//.match(line))
      id = -2 #no teacher assigned yet
    else
      name = ""
      matches_link = line.match(/#{room}\s+<a href=.*>([A-Z-,\s\.]+)<\/a>\s+[OpenClosed0-9]+/i)
      if(!matches_link.nil?)
        name = matches_link[1]
      else
        matches_no_link = line.match(/#{room}\s+([A-Z-,\s\.]+)\s+[OpenClosed\d]+/)
        if(!matches_no_link.nil?)
          name = matches_no_link[1]
        else
          return -1 #not found
        end
      end
      if(/,/.match(name))  #BRIGGS,DAVID G  to DAVID G BRIGGS
        name_split = name.split(",")
        name = name_split[1].strip + " " + name_split[0].strip
      end
      if(name.strip.empty?)
        return -1 #not found
      else
        teacher = Teacher.find_by_name(name)
        if(!teacher.nil?)
          id = teacher.id
        else
          teacher = Teacher.create(:name => name)
          id = teacher.id
        end
      end
    end
    return id
  end
  
  def self.get_crnc(line)
    return !(/CR\/NC/.match(line).nil?)
  end
  
  def self.assign_enrollment_ratio(c, line)
    matches = line.match(/([0-9]+)\/\s*([0-9]+)E?\s+/)
    c.students_enrolled = matches[1].to_i
    c.enrollment_space = matches[2].to_i
  end
  
  def self.is_line_of_class_times(line)
    return /\sM\s/.match(line)   ||
           /\sMT/.match(line)    ||
           /\sMW/.match(line)    ||
           /\sMTh/.match(line)   ||
           /\sMF\s/.match(line)  ||
           /\sT\s/.match(line)   ||
           /\sTW/.match(line)    ||
           /\sTTh/.match(line)   ||
           /\sTF\s/.match(line)  ||
           /\sW\s+\d/.match(line)||
           /\sWTh/.match(line)   ||
           /\sWF\s/.match(line)  ||
           /\sTh\s/.match(line)  ||
           /\sThF\s/.match(line) ||
           /\sF\s/.match(line)
  end

  def self.process_line_of_class_times(c, line)
    puts("I'm looking at line #{line}\n")
    matches = line.match(/([MTWhF]+)\s+([0-9]+)-([0-9P]+)\s+.*>([A-Z]+)<\/A>\s+([A-Z0-9]+)/)
    if(!matches.nil?)
      days_of_week = matches[1]
      start_time_string = matches[2]
      end_time_string = matches[3]
      times = build_times_array(days_of_week, start_time_string, end_time_string)
      abbrev = matches[4]
      building = Building.find_by_abbrev(abbrev)
      if(building.nil?) #building is already in there
        building = Building.create(:abbrev => abbrev)
        building.save()
      end
      room = matches[5]
      c.rendezvous.push(Rendezvous.new(:times=>times, :room=>room, :building_id=>building.id))
    end  
  end 
  
  def self.get_course_fee(line)
    matches = line.match(/\s+\$([0-9]+)\s+/)
    if(!matches.nil?)
      return "Course fee: $#{matches[1]}."
    else
      return ""
    end
  end 
  
  def self.get_additional_info(line)
    matches = line.match(/([DHJRSW%#]+)\s*$/)
    if(!matches.nil?)
       return Course.get_additional_info(matches[1])
    end
  end

end