class Course < ActiveRecord::Base
  
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

  #status constants
  STATUS_CLOSED = 0
  STATUS_OPEN = 1
  STATUS_UNKNOWN = 2

  #credit type contants
  CREDITTYPE_NW = 0
  CREDITTYPE_QSR = 1
  CREDITTYPE_IS = 2 #I&S
  CREDITTYPE_VLPA = 3
  CREDITTYPE_UNKNOWN = 4
  CREDITTYPE_NOTLISTED = 5
  CREDITTYPE_C = 6 #composition
  
  #special char contstants
  ADDITIONALINFO_D = 0 #Distance learning (51% or more of the course instruction for this course is through some mode of distance learning) 
  ADDITIONALINFO_H = 1 #Honors section
  ADDITIONALINFO_J = 2 #Offered jointly with another course
  ADDITIONALINFO_R = 3 #Research
  ADDITIONALINFO_S = 4 #Service learning
  ADDITIONALINFO_W = 5 #Writing
  ADDITIONALINFO_PERCENT = 6 #New course, added to the General Catalog within one academic year
  ADDITIONALINFO_POUND = 7 #Course is not elligible for some or all types of financial aid
  
  def name
    return "#{self.deptabbrev} #{self.number}"
  end
  
  def self.get_credit_types(string_representation)
    elements = string_representation.split(/[,\/]/)
    types = []
    for element in elements
      element = element.strip
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
    if(quarter_id > 0 && quarter_id < 6)
      return QUARTER_DISPLAY_NAMES[quarter_id-1]
    else
      return "Unknown"
    end
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
  
end