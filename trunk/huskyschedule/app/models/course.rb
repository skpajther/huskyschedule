class Course < ActiveRecord::Base
  
  #include Advanced_Query_System
  
  belongs_to :teacher
  belongs_to :category, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :building
  belongs_to :quarter
  has_many :labs, :class_name => "Lab", :foreign_key => "parent_id"
  has_many :quiz_sections, :class_name => "QuizSection", :foreign_key => "parent_id"
  
  Course.partial_updates = false
  serialize :times
  serialize :credit_type
  serialize :rendezvous
  serialize :additional_info

  #status constants
  STATUS_CLOSED = 0
  STATUS_OPEN = 1
  STATUS_UNKNOWN = 2
  STATUS_STRINGS = ["Closed", "Open", "Unknown"]

  #credit type contants
  CREDITTYPE_NW = 0
  CREDITTYPE_QSR = 1
  CREDITTYPE_IS = 2 #I&S
  CREDITTYPE_VLPA = 3
  CREDITTYPE_UNKNOWN = 4
  CREDITTYPE_NOTLISTED = 5
  CREDITTYPE_C = 6 #composition
  CREDITTYPES = [
    #Displayed      stored in db
    ["NW",          CREDITTYPE_NW], 
    ["QSR",         CREDITTYPE_QSR],
    ["I&S",         CREDITTYPE_IS],
    ["VLPA",        CREDITTYPE_VLPA],
    ["C",           CREDITTYPE_C],
    ["Unknown",     CREDITTYPE_UNKNOWN],
    ["Not Listed",  CREDITTYPE_NOTLISTED]
  ]
  CREDITTYPES_TOOLTIP = " 
  NW: The Natural World
  <br>QSR: Quantitative and Symbolic Reasoning
  <br>I&S: Individuals and Societies
  <br>VLPA: Visual, Literary, and Performing Arts
  <br>C: Composition
  "
  
  #special char contstants
  ADDITIONALINFO_D = 0 #Distance learning (51% or more of the course instruction for this course is through some mode of distance learning) 
  ADDITIONALINFO_H = 1 #Honors section
  ADDITIONALINFO_J = 2 #Offered jointly with another course
  ADDITIONALINFO_R = 3 #Research
  ADDITIONALINFO_S = 4 #Service learning
  ADDITIONALINFO_W = 5 #Writing
  ADDITIONALINFO_PERCENT = 6 #New course, added to the General Catalog within one academic year
  ADDITIONALINFO_POUND = 7 #Course is not elligible for some or all types of financial aid
  ADDITIONALINFO_TOOLTIP = "
  D: Distance learning (51% or more of the course instruction for this course is through some mode of distance learning) 
  <br>H: Honors section
  <br>J: Jointly offered course (Select the SLN to see Joint Curriculum)
  <br>R: Research
  <br>S: Service learning
  <br>W: Writing section
  <br>%: New course 
  <br>#: Not eligible for some or all types of Financial Aid"
  ADDITIONALINFOS = [
   #Displayed   stored in db
      ["D", ADDITIONALINFO_D], 
      ["H", ADDITIONALINFO_H],
      ["J", ADDITIONALINFO_J],
      ["R", ADDITIONALINFO_R],
      ["S", ADDITIONALINFO_S],
      ["W", ADDITIONALINFO_W],
      ["%", ADDITIONALINFO_PERCENT],
      ["#", ADDITIONALINFO_POUND]
  ]
  
  # Number of records per page
  RECORDS_PER_PAGE = 10;
  
  def name
    return "#{self.deptabbrev} #{self.number}"
  end
  
  def get_all_times
    ret = []
    for rende in self.rendezvous
      ret += rende.times
    end
    return ret
  end
  
  def buildings_parameters
    result = ""
    self.rendezvous.each{|rend|
      building = Building.find(rend.building_id)
      result = result + ", #{building.id}"
    }
    return result
  end
  
  def self.get_credit_types(string_representation)
    elements = string_representation.split(/[,\/]/)
    types = []
    for element in elements
      element.strip!
      if(element == "NW")
        types.push(CREDITTYPE_NW)
      elsif(element == "QSR")
        types.push(CREDITTYPE_QSR)
      elsif(element == "I&S")
        types.push(CREDITTYPE_IS)
      elsif(element == "VLPA")
        types.push(CREDITTYPE_VLPA)
      elsif(element == "C")
        types.push(CREDITTYPE_C)
      else
        types.push(CREDITTYPE_UNKNOWN)
      end
    end
    return types    
  end  
  
  def self.get_additional_info(string) 
    chars = string.split(//)
    types = []
    for char in chars
      if(char == "D")
        types.push(ADDITIONALINFO_D)
      elsif(char == "H")
        types.push(ADDITIONALINFO_H)
      elsif(char == "J")
        types.push(ADDITIONALINFO_J)
      elsif(char == "R")
        types.push(ADDITIONALINFO_R)
      elsif(char == "S")
        types.push(ADDITIONALINFO_S)
      elsif(char == "W")
        types.push(ADDITIONALINFO_W)
      elsif(char == "%")
        types.push(ADDITIONALINFO_PERCENT)
      elsif(char == "#")
        types.push(ADDITIONALINFO_POUND)
      end
    end
    types.sort!
    return types
  end
  
  def self.get_status(line)
    if(/Open/.match(line))
      return STATUS_OPEN
    elsif(/Closed/.match(line))
      return STATUS_CLOSED
    else
      return STATUS_UNKNOWN
    end    
  end
  
  def self.quarter_disp_name(quarter_id)
    if(quarter_id > 0 && quarter_id < 5)
      return Quarter.QUARTER_DISPLAY_NAMES[quarter_id-1]
    else
      return "Unknown"
    end
  end
  
  def self.find_by_building_quarter_year_day(building_id, quarter_id, year, day, overall_times)
    courses = Course.find(:all, :conditions=>"buildings LIKE '%#{building_id}%' AND quarter_id=#{quarter_id} AND year=#{year}")
    courses.delete_if {|course| !Rendezvous.relevant_rendezvous(course.rendezvous, building_id, day, overall_times) }
    return courses
  end
  
  def self.date_to_weeknum(date)
    return (date.wday-1*48)+(date.hour*2)+((date.min+20)%30)
  end
  
  def self.compatible(courseA, courseB)
    a = courseA.get_all_times()
    b = courseB.get_all_times()
    
    a.sort!{|x,y| date_to_weeknum(x[0])<=>date_to_weeknum(y[0])}
    b.sort!{|x,y| date_to_weeknum(x[0])<=>date_to_weeknum(y[0])}
    i = 0
    j = 0
    while(i<a.length && j<b.length)
      ai = a[i]
      bj = b[j]
      if(ai[0] < bj[0])
        if(ai[1] >= bj[1])
          return false
        else
          i += 1
        end
      elsif(bj[0] < ai[0])
        if(bj[1] >= ai[1])
          return false
        else
          j += 1
        end
      else
        return false
      end
    end
    return true
  end
  
  def self.find_or_count_by_limitors(options={})
    options[:model] = "courses"
    return self.general_find_or_count_by_limitors(options)
  end
  
  def self.general_find_or_count_by_limitors(options={})
    if(options[:model]!=nil)
      model = options[:model]
      limitors_name = :limitors
      
      if(options[:limitors_name]!=nil)
        limitors_name = options[:limitors_name]
      end
      
      query = ""
      first = true
      if(options[limitors_name]!=nil)
        limitors = options[limitors_name]
        if(limitors["custom"]!=nil)
          for q in limitors["custom"]
            if(first)
              query += "#{q}"
              first = false
            else
              query += " AND #{q}"
            end
          end
        end
        limitors.each_key{ |k|
          if(k!="custom" && k!="order")
  #          k2 = k
  #          if(k=="category_id")
  #            k2 = "parent_id"
  #          end
            st = ""
            if(k=="parent_id" && limitors[k].is_a?(String))
              st = "#{limitors[k]}"
            elsif(k=="course_name" && model=="courses")
              tmp_arr = limitors[k].split(' ')
              if(tmp_arr!=nil && tmp_arr.length == 2)
                st = "courses.deptabbrev='#{tmp_arr[0]}' AND courses.number=#{tmp_arr[1]}"
              end
            elsif(k=="specific_quarter")
              tmp_arr = limitors[k].split("..")
              if(model=="course_reviews")
                st = "course_reviews.quarter_taken=#{tmp_arr[0]} AND course_reviews.year_taken=#{tmp_arr[1]}"
              elsif(model=="courses")
                st = "courses.quarter_id=#{tmp_arr[0]} AND courses.year=#{tmp_arr[1]}"
              end
            else
              st = "#{model}.#{k}='#{limitors[k]}'"
            end
            if(!first)
              st = " AND #{st}"
            end
            query += st
            first = false
          end
        }
      end
      puts("query!!! #{query} #{limitors.inspect}")
      return self.general_find_or_count_by_sql(query, options)
    end
    return nil
  end
  
  def self.find_or_count_by_sql(query, options={})
    options[:model] = "courses"
    return self.general_find_or_count_by_sql(query, options)
  end
  
  def self.general_find_or_count_by_sql(query, options={})
    if(options[:model]!=nil)
      model_instance = self
      model = options[:model]
      select_substitute = "SELECT * FROM"
      
      if(options[:model_instance]!=nil)
        model_instance = options[:model_instance]
      end
      if(options[:select_substitute]!=nil)
        select_substitute = options[:select_substitute]
      end
      
      if(options.key?(:count_only) && options[:count_only])
        if(query==nil || query.length == 0)
          query = "FROM #{model}"
        else
          query = "FROM #{model} WHERE "+query
        end
        courses = model_instance.count_by_sql("SELECT COUNT(*) "+query)
      else
        order_by_str = ""
        if(options.key?(:order_by))
          tmp = options[:order_by].sub(/[{,(].*[},)]/, "")
          order_by_str = " ORDER BY "+tmp
          if(options.key?(:descending))
            order_by_str += ((options[:descending]==false.to_s)? " ASC" : " DESC")
          end
        end
        if(options.key?(:table_name) && options.key?(:foreign_key))
          query = "SELECT #{model}.* FROM #{model} LEFT JOIN "+options[:table_name]+" ON #{model}."+options[:foreign_key]+"="+options[:table_name]+".id WHERE ("+query+")"
        elsif(query==nil || query.length == 0)
          query = "#{select_substitute} #{model}"
        else
          query = "#{select_substitute} #{model} WHERE "+query
        end
        if(options.key?(:page) && options[:page]!=false)
          courses = model_instance.paginate_by_sql(query+order_by_str, :page => options[:page], :per_page => options[:per_page])
        else
          courses = model_instance.find_by_sql(query+order_by_str)
        end
      end
      return courses
    end
    return nil
  end

end

class Rendezvous
  attr_accessor :times, :building_id, :room
  
  def initialize(options = {})
    if(options[:times]!=nil)
      if(options[:times].kind_of? Array)
        @times = options[:times]
      else
        raise Exception.new("times must be an Array")
      end
    end
    if(options[:building_id]!=nil)
      if(options[:building_id].kind_of? Fixnum)
        @building_id = options[:building_id]
      else
        raise Exception.new("building_id must be a Fixnum")
      end
    end
    if(options[:room]!=nil)
      if(options[:room].kind_of? String)
        @room = options[:room]
      else
        raise Exception.new("room must be a String")
      end
    end
  end
 
  #passed an array of Rendezvous objects
  #at least one of the Rendezvous objects has the correct building, or this would not have been called
  #pass by reference, so will manipulate original rendezvous array which was passed
  #returns true if one rendezvous object in the given array meets in the given building at least once on the given day
  #updates the array to contain only relevant data
  def self.relevant_rendezvous(rendezvous, building_id, day, overall_times)
    rendezvous.delete_if{|rendezvous_s| 
      !(rendezvous_s.building_id == building_id && Rendezvous.relevant_times(rendezvous_s.times, day, overall_times))
    }
    #if rendezvous.length > 0, there is at least one rendezvous object remaining
    #with the correct building with only meetings on the correct day
    #further, rendezvous only contains entries with the correct building and correct day only
    return rendezvous.length > 0
  end
  
  #prunes the given array of start,stop times to those only on the given day
  #true if the times had any on the given day
  def self.relevant_times(times, day, overall_times)
    times.delete_if{|start_stop| start_stop[0].wday != day } #strip times[] down to only the day we want
    if(times.length > 1)
      raise Exception.new("One rendezvous meets in the same building, in the same room on the same day at two different times")
    end
    times.each{|start_stop| 
      if(!overall_times.include?(start_stop[0])) #adds the start times of the course to overall_times
        overall_times.push(start_stop[0]) 
      end
    }
    return times.length > 0
  end
  
  #creates strings in the form 
  def self.time_string(rende)
    s = ""
    #all times in this rendezvous will have the same start/stop, just different days
    start_h = rende.times[0][0].hour
    start_am = start_h < 12
    start_h = military_to_standard_hour(start_h)
    start_m = rende.times[0][0].min
    start_s = start_h.to_s + ":" + ((start_m == 0)? "00" : start_m.to_s) + ((start_am)? "a" : "p")
    end_h = rende.times[0][1].hour
    end_am = end_h < 12
    end_h = military_to_standard_hour(end_h)
    end_m = rende.times[0][1].min
    end_s = end_h.to_s + ":" + ((end_m == 0)? "00" : end_m.to_s) + ((end_am)? "a" : "p")
    time_s = start_s + " - " + end_s
    for time in rende.times
      s << Quarter::DAY_DISPLAY_NAMES[time[0].wday-1]
    end
    s << " " + time_s
    return s
  end
  
  def self.military_to_standard_hour(hour)
    if(hour>12)
      hour -= 12
    end
    return hour
  end
  
end