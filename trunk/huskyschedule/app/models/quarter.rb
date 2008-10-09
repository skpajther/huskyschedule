class Quarter < ActiveRecord::Base
  
  has_many :courses
  has_many :course_ratings
  
  QUARTER_AUTUMN = 1
  QUARTER_WINTER = 2
  QUARTER_SPRING = 3
  QUARTER_SUMMER = 4
  
  QUARTER_TYPES = [
    # Displayed        stored in db
    [ "Autumn",         QUARTER_AUTUMN ],
    [ "Winter",           QUARTER_WINTER ],
    [ "Spring",        QUARTER_SPRING ],
    [ "Summer",           QUARTER_SUMMER ]
  ]
  
end
