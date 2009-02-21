class Category < ActiveRecord::Base
  
  has_many :courses, :class_name => "Course", :foreign_key => "parent_id"
  has_many :children, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Category", :foreign_key => "parent_id"
  
  DESCRIPTION_URL = "http://www.washington.edu/students/crscat/"
  
  def all_children
    ret = []
    for child in self.children
      ret.push(child)
      ret = ret + child.all_children
    end
    return ret
  end
  
  def all_children_query_string
    st = ""
    if(self.children.size > 0)
      st = ","
    end
    return "courses.parent_id IN (#{self.id}#{st}#{self.all_children.map{|child| child.id }.inspect.delete!('[]')})"
  end
  
end
