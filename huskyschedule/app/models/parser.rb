class Parser < ActiveRecord::Base
  
  def self.get_html_array(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    return response.body.split("\n")
  end
  
  #remove &nbps; and &amp;
  def self.clean_text(text)
    split = text.split("&nbsp;")
    result = ""
    for s in split
      result += " " + s
    end
    split = result.split("&amp;")
    if(!split.nil?)
      result = split[0]
      1.upto(split.length-1) { |i| result += "&" + split[i] }
    end
    return result.strip
  end
    
#################################################################################################
#parser for list of categories
#################################################################################################
  def self.time_schedule_parser(url)
    contents = get_html_array(url)
    quarter = -1
    year = -1
    
    #get quarter, year
    i=0
    while(i < contents.length)
      matches = contents[i].match(/^<H1>University of Washington Time Schedule<BR>([^\s]+)\s+Quarter\s+([0-9]+)<\/H1>$/i)
      if(!matches.nil?)
        quarter = Quarter.quarter_constant(matches[1])
        year = matches[2].to_i
        break
      else
        i+=1
      end
    end
    
    #clear entire db
    #sql.execute("DELETE FROM categories")
    #sql.execute("DELETE FROM teachers")
    
    courses = Course.find(:all, :conditions=>"quarter_id = #{quarter} AND year = #{year}")
    for c in courses
      Course.delete(c.id)
      QuizSection.delete_all(:parent_id=>c.id)
      Lab.delete_all(:parent_id=>c.id)
    end
    
    Category.create_all_categories
    i=50
    
    #DO VERK
    categories = Category.find(:all, :conditions=>"url != ''")
    for category in categories
      category_parser(url+category.url, category.url, category.abbrev, quarter, year, category.id)
    end
    
    
    abbrev = "CSE"
    url_L = "cse.html"
    cat = Category.find(:first, :conditions=>"abbrev = '#{abbrev}'")
    category_parser(url+url_L, url_L, abbrev, quarter, year, cat.id)
    #use these to parse one section only
    abbrev = "INFO"
    url_L = "info.html"
    cat = Category.find(:first, :conditions=>"abbrev = '#{abbrev}'")
    category_parser(url+url_L, url_L, abbrev, quarter, year, cat.id)
  end
  
  #  def self.time_schedule_parser(url)
#    
#    sql.execute("DELETE FROM huskyschedule_development.categories")
#    active_subcategory = nil
#    contents = get_html_array(url)
#    i=0
#    while(i < contents.length) #main loop
#      line = contents[i]
#      if(/^<a name=/i.match(line) && !(/<!--/.match(contents[i-1]))) #no html comment before
#        #processing a college
#        #<P><B><a name="O">College of Ocean and Fishery Sciences</a></B><BR>
#        matches = line.match(/^<A name="(.*)"><B>([^<]+)</i)
#        if(matches.nil?)
#          matches = line.match(/^<P><B><A NAME="(.*)">([^<]+)<\/A>/i)
#        end
#        if(!matches.nil?)
#          abbrev = matches[1] #what to do with this
#          college_name = clean_text(matches[2])
#          if(college_name == "Extended MPH Degree Program")
#            break
#          end
#          puts("College name: #{college_name}\n\n")
#          college = Category.create(:name=>college_name, :abbrev=>"College")
#          college.save()
#          i+=1
#          while(i < contents.length) #ready to loop through categories of the college, <UL> loop
#            line2 = contents[i]
#            if(/^<UL>/i.match(line2)) #main <UL> for an entire college
#              i+=1
#              while(i < contents.length) #<LI> loop
#                line3 = contents[i]
#                if((/^<LI>.*<\/LI>/i.match(line3) && !/<a/i.match(line3)) ||
#                   ((/^<LI>/i.match(line3) && !(/<a/i.match(line3))) || 
#                   (/^<LI><A name/i.match(line3))) && 
#                   !(/^<LI>.*<\/LI>/i.match(line3) && !/<a/i.match(line3))) #sub categories
#                  matches = line3.match(/^<LI><A NAME=.*>(.*)<\/A>/i)
#                  if(matches.nil?)
#                    matches = line3.match(/^<LI>(.*)<\/LI>$/i)
#                    if(matches.nil?)
#                      matches = line3.match(/^<LI>(.*)$/i)
#                    end
#                  end
#                  category_name = clean_text(matches[1].strip)
#                  category = Category.create(:name=>category_name, :abbrev=>"Top Category")
#                  category.parent_id = college.id
#                  category.save()
#                  puts("Found a topcat #{category.name}\n")
#                  while(i < contents.length) #sub categories
#                    line4 = contents[i]
#                    if(/^<LI><A/.match(line4) && !(/<\/A>/.match(line4)))
#                      i+=1
#                      line4 += " " + contents[i]
#                    end
#                    matches_subcategory = line4.match(/^<LI><A HREF=([A-Za-z\.]+)>(.*)<\/A>/i)
#                    if(!matches_subcategory.nil?)
#                      subcategory_url = matches_subcategory[1]
#                      subcategory_name = clean_text(matches_subcategory[2])
#                      sub_category = Category.new(:name=>subcategory_name, :parent_id=>category.id)
#                      sub_category.save()
#                      puts("Found a subcat #{sub_category.name}\n\n")
#                      #category_parser(url+subcategory_url, sub_category.id)
#                      i+=1 #continue searching
#                    elsif(/^<\/LI>$/i.match(line4) || /^<\/UL><\/LI>$/i.match(line4) || /^<\/UL>$/i.match(line4))
#                      i+=1
#                      puts("Breaking out of subcat loop i=#{i}\n\n")
#                      break #done processing sub categories
#                    else
#                      i+=1
#                    end
#                  end #done processing sub categories
#                elsif(/^<LI>/i.match(line3) && /^<LI><A/i.match(line3) && !(/<!--/.match(contents[i-1])) && !/see\s/i.match(line3))
#                  if(/^<LI><A/.match(line3) && !(/<\/A>/.match(line3)))
#                    i+=1
#                    line3 += " " + contents[i]
#                  end
#                  matches = line3.match(/^<LI><A.*=([^>]+)>(.*)<\/A>/i)
#                  category_url = matches[1]
#                  category_name = clean_text(matches[2])
#                  category = Category.new(:name=>category_name, :parent_id=>college.id)
#                  category.save()
#                  puts("Found a category #{category.name}\n\n")
#                  #category_parser(url+category_url, category.id)
#                  i+=1 #continue searching
#                elsif(/^<\/UL>/i.match(line3))
#                  puts("breaking out of college loop i=#{i}\n\n")
#                  break #out of <LI> loop
#                else
#                  i+=1
#                end
#              end
#            elsif(/^<\/UL>$/i.match(line2) || /^<div id="footer">/i.match(line2)) #end of this college's data
#              break #out of <UL> loop
#            else #if(/^<UL>/i.match(line_category))
#              i+=1
#            end
#          end
#        else #matches = line.match(/^<A name="(.*)"><B>(.*)<\/B>/i) if(!matches.nil?)
#          i+=1
#        end
#      elsif(/^<div id="footer">/i.match(line))
#        break
#      else #if(/^<a name=/i.match(line) && !(/<!--/.match(contents[i-1]))) no html comment before
#        i+=1
#      end
#    end #main while loop
#    return "Complete."
#  end
    
#################################################################################################  
#parser for a specific category   
#################################################################################################
  
  def self.category_parser(url, cat_url, dept_abbrev, quarter, year, parent_id)
    contents = get_html_array(url)
    #variables to be filled
    active_lecture = nil
    course_description_contents = get_html_array(Category::DESCRIPTION_URL + cat_url) #load this once
    #end variables to be filled
    
    i=0 #main counter for the parser
    
    while(i<contents.length)
      line = contents[i]
      if(/^<br>$/i.match(line))
        #beginning a course
        i+=1
        while(i<contents.length)
          line = contents[i]
          matches = line.match(/NAME=([A-Za-z]+)([0-9]+)>/i) #<A NAME=academ198>
          if(!matches.nil?) #ready to process all lectures/quiz sections of a course
            course_number = matches[2].to_i
            course_title = get_course_title(line, course_description_contents, course_number)
            course_description = get_course_description(line, course_description_contents, course_number)
            #puts("Course description = #{course_description}")
            credit_type = get_credit_type(line)
            puts("Parsing #{dept_abbrev} #{course_number}\n")
            while(i<contents.length) #ready to start gathering data about the lectures/sections
              line2 = contents[i]
              matches2 = line2.match(/SLN=([0-9]{5})>/i)
              if(!matches2.nil?) #process this class's data
                sln = matches2[1].to_i
                section = get_section(line2, sln)
                c = nil
                lab_or_quiz = section.length > 1
                if(!lab_or_quiz) #lecture
                  c = Course.create(:deptabbrev=>dept_abbrev, :number=>course_number, :title=>course_title, :credit_type=>credit_type, :quarter_id=>quarter, :year=>year)
                  begin #stupid edge case because one course's description had a character 'ø' and I can't plug that into a regex
                    c.description = course_description
                    c.save()
                  rescue
                    c.description = "See #{Category::DESCRIPTION_URL}#{cat_url} for description."
                  end
                  active_lecture = c
                  c.parent_id = parent_id
                elsif(/QZ/.match(line2))
                  c = QuizSection.create(:parent_id=>active_lecture.id)
                else #quiz section
                  c = Lab.create(:parent_id=>active_lecture.id)
                end
                c.sln = sln
                c.section = section
                i = process_course(c, i, contents, line2, lab_or_quiz)
                c.save
                if(!lab_or_quiz) #lecture
                  #CourseReview.recalculate_review_info(c, nil)
                end
                
              elsif(/^<br>$/i.match(line2) || /to be arranged/i.match(line2))
                break
              else
                i+=1 #continue advancing through the lines
              end
            end
          elsif(/^<br>$/i.match(line))
            break
          else
            i+=1 #continue advancing through the lines
          end
        end #finished processing a course  
      elsif(!(line.match(/^<div id="footer"/i).nil?))
        break
      else
        i+=1 #continue advancing through the lines
      end
    end #outer-most while loop
  end
  
  def self.process_course(c, i, contents, line, lab_or_quiz)
    if(/to be arranged/i.match(line))
      return i+1
    else
      if(!lab_or_quiz)
        assign_credit_amount(c, line, c.sln, c.section)
        c.restricted = get_restricted(line)
      end
      c.additional_info = get_additional_info(line)
      times = get_times(c.sln, c.section, line)
      building_id = get_building_id(line)
      building = Building.find_by_id(building_id)
      if(building_id != Building::BUILDING_NOTFOUND)
        room = get_room(line, building.abbrev)
        if(room != "Not listed")
          c.teacher_id = get_teacher_id(room, line)
        else
          c.teacher_id = get_teacher_id_no_room(building.abbrev, line)
        end
      else
        room = "Not listed"
      end
      c.rendezvous = [Rendezvous.new(:times=>times, :building_id=>building_id, :room=>room)]
      c.crnc = get_crnc(line)
      c.status = Course.get_status(line)
      assign_enrollment_ratio(c, line)
      if(c.description.nil?)
        c.description = ""
      end
      c.description += get_course_fee(line)
      #notes
      i+=1
      notes = ""
      puts(c.inspect)
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
      c.notes = check_notes(notes)
      puts(c.inspect)
      c.times = times
      buildings = []
      for rendezvous in c.rendezvous
        buildings.push(rendezvous.building_id)
      end
      c.buildings = buildings
      return i
    end
  end
  
  def self.clean_text(text, find)
    split = text.split(find)
    if(split.length > 0)
      result = ""
      for s in split
        result += " " + s.strip
      end
      puts("HERE bad = #{find}")
      return result.strip
    else
      return text.strip
    end
  end
  
  def self.check_notes(notes)
    bad = "\377"
    return clean_text(notes, bad) #stupid edge case
  end
  
  def self.get_course_title(line, course_description_contents, course_number)
    contents = course_description_contents
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
    #not found in course_description_contents
    matches = line.match(/<a href=.*#{course_number}>(.*)<\/A>/i)
    if(matches.nil?)
      return "NOT FOUND" 
    else
      return matches[1]
    end
  end
  
  def self.get_course_description(line, course_description_contents, course_number)
    contents = course_description_contents
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
    matches = line.match(/<b>\(([^\)]+)\)<\/b>/i)
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
    matches = line.match(/#{sln}<\/A>\s([A-Z0-9]+)\s+/i)
    if(!matches.nil?)
       return matches[1]
    else
      return "error finding section on line #{line}"
    end
  end
  
  def self.assign_credit_amount(c, line, sln, section)
    matches = line.match(/>#{sln}<\/A>\s+#{section}\s+([0-9-]+)/i)
    if(matches.nil?)
      matches2 = line.match(/#{sln}.*>.*<\/A>\s+#{section}\s+[^\d]+/i) #"VAR" or something else
      if(!matches2.nil?)
        c.credits = 1
        c.variable_credit = 11 #Max # of credits i've seen
      else
        c.credits = -1 #error
      end
    else
      credits = matches[1]
      if(/-/.match(credits))
        split = credits.split(/-/)
        c.credits = split[0].to_i #lowest = most significant
        c.variable_credit = split[1].to_i #highest = variable
      else
        c.credits = credits.to_i
      end
    end
  end
  
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
      times.push([Time.parse(start_time_string, now = Quarter::MONDAY), Time.parse(end_time_string, now = Quarter::MONDAY)])
    end
    if(/TW/.match(days_of_week) || /TTh/.match(days_of_week) || /TF/.match(days_of_week) || /T$/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = Quarter::TUESDAY), Time.parse(end_time_string, now = Quarter::TUESDAY)])
    end
    if(/W/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = Quarter::WEDNESDAY), Time.parse(end_time_string, now = Quarter::WEDNESDAY)])
    end
    if(/Th/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = Quarter::THURSDAY), Time.parse(end_time_string, now = Quarter::THURSDAY)])
    end
    if(/F/.match(days_of_week))
      times.push([Time.parse(start_time_string, now = Quarter::FRIDAY), Time.parse(end_time_string, now = Quarter::FRIDAY)])
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
      return Building.get_building_id(building_abbrev)
    else
      return Building::BUILDING_NOTFOUND
    end  
  end
  
  def self.get_room(line, building_abbrev)
    matches = line.match(/>#{building_abbrev}<\/a>\s+([0-9A-Z]+)\s+/i)
    return (matches.nil?)? "Not listed" : matches[1]
  end
  
  def self.get_teacher_id(room, line)
    id = 0
    if(/#{room}\s+\d+\//.match(line))
      return Teacher::TEACHER_NOTLISTED 
    else
      name = ""
      matches_link = line.match(/\s+#{room}\s+<a href=.*>([^<]+)<\/a>\s+[OpenClosed0-9]+/i)
      if(!matches_link.nil?)
        name = matches_link[1]
      else
        matches_no_link = line.match(/#{room}\s+([A-Z-,\s\.]+)\s+[OpenClosed\d]+/)
        if(!matches_no_link.nil?)
          name = matches_no_link[1]
        else
          return Teacher::TEACHER_NOTLISTED
        end
      end
      return Teacher.get_teacher_id(name)
    end
  end
  
  #for when the room number isn't given
  def self.get_teacher_id_no_room(building_abbrev, line)
    id = 0
    matches_link = line.match(/>#{building_abbrev}<\/A>\s+<A HREF=.*>([^<]+)<\/A>/i)
    name = ""
    if(matches_link.nil?)
      matches_no_link = line.match(/<#{building_abbrev}<\/A>\s+([A-Z-,\s\.]+)\s+[OpenClosed\d]+/i)
      if(matches_no_link.nil?)
        return Teacher::TEACHER_NOTFOUND
      else
        name = matches_no_link[1]
      end
    else
      name = matches_link[1]
    end
    return Teacher.get_teacher_id(name)
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