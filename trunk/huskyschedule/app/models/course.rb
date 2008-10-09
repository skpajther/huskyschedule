class Course < ActiveRecord::Base
  
  belongs_to :teacher
  belongs_to :category, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :building
  belongs_to :quarter
  has_many :labs, :class_name => "Lab", :foreign_key => "parent_id"
  has_many :quiz_sections, :class_name => "QuizSection", :foreign_key => "parent_id"
  
  serialize :times
  serialize :credit_type
  
  QUARTER_AUTUMN = 1
  QUARTER_WINTER = 2
  QUARTER_SPRING = 3
  QUARTER_SUMMER = 4
  
  QUARTER_TYPES = [
    # Displayed        stored in db
    [ "Autmn",          QUARTER_AUTUMN ],
    [ "Winter",         QUARTER_WINTER ],
    [ "Spring",        QUARTER_SPRING ],
    [ "Summer",           QUARTER_SUMMER ]
  ]
  
end
