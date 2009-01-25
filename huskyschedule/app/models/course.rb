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
