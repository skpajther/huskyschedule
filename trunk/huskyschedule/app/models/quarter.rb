class Quarter < ActiveRecord::Base
  
  has_many :courses
  has_many :course_ratings
  
  QUARTER_AUTUMN = 1
  QUARTER_WINTER = 2
  QUARTER_SPRING = 3
  QUARTER_SUMMER = 4
  CURRENT = QUARTER_AUTUMN
  
  QUARTER_DISPLAY_NAMES = ["Autumn", "Winter", "Spring", "Summer"]
    
  QUARTER_TYPES = [
    # Displayed        stored in db
    [ QUARTER_DISPLAY_NAMES[0],        QUARTER_AUTUMN ],
    [ QUARTER_DISPLAY_NAMES[1],        QUARTER_WINTER ],
    [ QUARTER_DISPLAY_NAMES[2],        QUARTER_SPRING ],
    [ QUARTER_DISPLAY_NAMES[3],        QUARTER_SUMMER ]
  ]
  
  #days constants
  MONDAY = Time.parse("Monday January 26, 2009")
  TUESDAY = Time.parse("Tuesday January 27, 2009")
  WEDNESDAY = Time.parse("Wednesday January 28, 2009")
  THURSDAY = Time.parse("Thursday January 29, 2009")
  FRIDAY = Time.parse("Friday January 30, 2009")
  
  #get the display name for the given constant
  def self.quarter_disp_name(quarter_id)
    if(quarter_id > 0 && quarter_id < 6)
      return QUARTER_DISPLAY_NAMES[quarter_id-1]
    else
      return "Unknown"
    end
  end
  
  #get the constant for the given display name
  def self.quarter_constant(quarter_display_name)
    QUARTER_DISPLAY_NAMES.size.times{ |i|
      if(QUARTER_DISPLAY_NAMES[i] == quarter_display_name)
        return i+1
      end
    }
    return -1
  end   
 
  #find all quarters we've parsed
  def self.find_distinct_quarters
    results = []
    sql = ActiveRecord::Base.connection();
    quarters = sql.execute("SELECT DISTINCT quarter_id,year FROM courses")
    quarters.each { |quarter|
      quarter_id = quarter[0].to_i
      year = quarter[1].to_i
      results.push(DistinctQuarter.new(:quarter_id=>quarter_id, :year=>year))
    }
    results.sort!{ |x,y| y<=>x } #sorts from most recent quarter to least
    return results
  end
  
  #returns the quarter in distinct_quarters with the given quarter_id and year
  #returns the first quarter if none were found
  def self.find_correct_quarter(distinct_quarters, quarter_id, year)
    distinct_quarters.each{ |quarter|
      if(quarter.quarter_id == quarter_id && quarter.year == year)
        return quarter
      end
    }
    return distinct_quarters[0]
  end
  
end

class DistinctQuarter
  attr_accessor :quarter_id, :year, :active
  
  def initialize(options = {})
    @active = false
    if(!options[:quarter_id].nil?)
       if(options[:quarter_id].kind_of? Fixnum)
         @quarter_id = options[:quarter_id]
       else
         raise Exception.new("quarter_id must be Fixnum")
       end
    end
    if(!options[:year].nil?)
      if(options[:year].kind_of? Fixnum)
        @year = options[:year]
      else
        raise Exception.new("year must be fixnum")
      end
    end
  end
  
  include Comparable
 
  #if this<other, other is a newer time schedule
  def <=>(other)
    if(@year == other.year && @quarter_id == other.quarter_id)
      return 0
    elsif(@year == other.year)
      if(@quarter_id == Quarter::QUARTER_AUTUMN)
        return 1
      elsif(other.quarter_id == Quarter::QUARTER_AUTUMN)
        return -1
      else #Winter, Spring, or Summer
        if(@quarter_id < other.quarter_id)
          return -1
        else
          return 1
        end
      end
    else #years not equal
      if(@year < other.year)
        return -1
      else
        return 1
      end
    end
  end
  
  def to_s
    quarter_s = Quarter.quarter_disp_name(@quarter_id)
    return "#{quarter_s} #{@year.to_s}"
  end
  
end #DistinctQuarter

class DistinctQuarterData
  attr_accessor :distinct_quarter, :courses, :quiz_sections, :labs
  
  def initialize(options = {})
    if(!options[:distinct_quarter].nil?)
       if(options[:distinct_quarter].kind_of? DistinctQuarter)
         @distinct_quarter = options[:distinct_quarter]
       else
         raise Exception.new("distinct_quarter must be of type DistinctQuarter")
       end
    end   
    if(!options[:courses].nil?)
      if(options[:courses].kind_of? Array)
        @courses = options[:courses]
      else
        raise Exception.new("courses must be an array")
      end
    end
    if(!options[:labs].nil?)
      if(options[:labs].kind_of? Array)
        @labs = options[:labs]
      else
        raise Exception.new("labs must be an array")
      end
    end
    if(!options[:quiz_sections].nil?)
      if(options[:quiz_sections].kind_of? Array)
        @quiz_sections = options[:quiz_sections]
      else
        raise Exception.new("quiz_sections must be an array")
      end
    end
  end #intialize
  
  def to_s
    quarter_s = Quarter.quarter_disp_name(@quarter_id)
    return "#{quarter_id.s} #{year.to_s}"
  end
  
  def quarter_id
    return @distinct_quarter.quarter_id
  end
  
  def year
    return @distinct_quarter.year
  end
  
end #DistinctQuarterData