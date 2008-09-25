class Category < ActiveRecord::Base
  
  has_many :courses
  has_many :categories, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :category
  
end
