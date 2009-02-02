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
    [ QUARTER_DISPLAY_NAMES[0],          QUARTER_AUTUMN ],
    [ QUARTER_DISPLAY_NAMES[1],         QUARTER_WINTER ],
    [ QUARTER_DISPLAY_NAMES[2],        QUARTER_SPRING ],
    [ QUARTER_DISPLAY_NAMES[3],           QUARTER_SUMMER ]
  ]
  
  def self.quarter_disp_name(quarter_id)
    if(quarter_id > 0 && quarter_id < 6)
      return QUARTER_DISPLAY_NAMES[quarter_id-1]
    else
      return "Unknown"
    end
  end
  
  def self.quarter_constant(quarter_display_name)
    QUARTER_DISPLAY_NAMES.size.times{ |i|
      if(QUARTER_DISPLAY_NAMES[i] == quarter_display_name)
        return i+1
      end
    }
    return -1
  end   
 
end
