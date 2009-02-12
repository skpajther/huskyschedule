class Category < ActiveRecord::Base
  
  has_many :courses, :class_name => "Course", :foreign_key => "parent_id"
  has_many :children, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Category", :foreign_key => "parent_id"
  
  DESCRIPTION_URL = "http://www.washington.edu/students/crscat/"
  
end
