class CourseRating < ActiveRecord::Base
  
  has_one :teacher
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  
end
