class Schedule < ActiveRecord::Base
  
  belongs_to :user
  
  Schedule.partial_updates = false
  serialize :courses
  
  def self.get_or_create_grab_bag(curr_user)
    attributes = {:user_id=>curr_user.id, :grab_bag=>true, :quarter=>Quarter::CURRENT, :year=>Time.now.year}
    schedule = Schedule.find(:first, :conditions => attributes)
    if(schedule==nil)
      schedule = Schedule.create(attributes)
      schedule.name = "#{curr_user.login}'s grab bag"
      schedule.courses = []
      schedule.save!
    end
    return schedule
  end
  
  def get_courses
    if(self.courses!=nil && self.courses.size > 0)
      return Course.find(:all, :conditions => "id IN (#{self.courses.inspect.delete!('[]')})")
    end
    return []
  end
  
  def self.add_to_schedule(schedule, course)
    if(schedule==nil)
      raise ScheduleError.new("No Schedule Given To Add To")
    end
    if(course==nil)
      raise ScheduleError.new("No Course Given To Add")
    end
    if(schedule.quarter!=course.quarter_id || schedule.year!=course.year)
      raise ScheduleError.new("Course And Schedule Differ in Quarter")
    end
    if(schedule.courses==nil)
      schedule.courses = []
    end
    schedule.courses.push(course.id)
    if(schedule.save)
      return "Course Added Successfully"
    else
      return "Course Failed to be Added"
    end
  end
  
  def self.get_schedules(curr_user, options={})
    results = Schedule.find(:all, :conditions=>{:user_id=>curr_user.id, :grab_bag=>false})
    if(options[:create_on_none]!=nil && options[:create_on_none]==true && results.length<=0)
      results = [Schedule.create(:user_id=>curr_user.id, :grab_bag => false, :courses=>[], :quarter => Quarter::CURRENT, :year => Time.now.year)]
    end
    return results
  end
  
  protected
  
  class ScheduleError < StandardError; end
  
end
