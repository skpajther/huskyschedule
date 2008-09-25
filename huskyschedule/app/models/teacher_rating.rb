class TeacherRating < ActiveRecord::Base
  
  has_one :teacher
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  belongs_to :course_taught, :class_name => "Course", foreign_key => "course_taught_id" 
  
end
