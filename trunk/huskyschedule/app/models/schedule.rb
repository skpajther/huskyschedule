class Schedule < ActiveRecord::Base
  
  belongs_to :user
  
  Course.partial_updates = false
  serialize :courses
  
  def self.get_grab_bag(curr_user)
      Schedule.find(:first, :conditions => {:user_id=>curr_user.id, :grab_bag=>true, :quarter=>Quarter::CURRENT, :year=>Time.now.year})
  end
  
  def get_courses
    if(self.courses!=nil && self.courses.size > 0)
      return Course.find(:all, :conditions => "id IN (#{self.courses.inspect.delete!('[]')})")
    end
    return []
  end
  
end
