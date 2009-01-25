class QuizSection < ActiveRecord::Base
  
  belongs_to :teacher
  belongs_to :course, :class_name => "Course", :foreign_key => "parent_id"
  belongs_to :building
  
  QuizSection.partial_updates = false
  serialize :times
  
  
end
