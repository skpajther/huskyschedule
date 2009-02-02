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
  
  #status constants
  STATUS_CLOSED = 0
  STATUS_OPEN = 1
  STATUS_UNKNOWN = 2

  #credit type contants
  CREDITTYPE_NW = 0
  CREDITTYPE_QSR = 1
  CREDITTYPE_W = 2
  CREDITTYPE_IS = 3 #I&S
  CREDITTYPE_J = 4
  CREDITTYPE_UNKNOWN = 5
  CREDITTYPE_NOTLISTED = 6
  CREDITTYPE_D = 7
  CREDITTYPE_H = 8
  CREDITTYPE_S = 9
  
  def self.get_credit_types(string_representation)
    elements = string_representation.split(",")
    types = []
    for element in elements
      element = element.strip
      if(element == "NW")
        types.push(CREDITTYPE_NW)
      elsif(element == "QSR")
        types.push(CREDITTYPE_QSR)
      elsif(element == "W")
        types.push(CREDITTYPE_W)
      elsif(element == "I&S")
        types.push(CREDITTYPE_IS)
      elsif(element == "J")
        types.push(CREDITTYPE_J)
      else
        types.push(CREDITTYPE_UNKNOWN)
      end
    end
    return types    
  end  
  
  def self.quarter_disp_name(quarter_id)
    if(quarter_id > 0 && quarter_id < 6)
      return QUARTER_DISPLAY_NAMES[quarter_id-1]
    else
      return "Unknown"
    end
  end
  
  def name
    return "#{self.deptabriev} #{self.number}"
  end
      
end
