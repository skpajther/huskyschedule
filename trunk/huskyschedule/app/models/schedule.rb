class Schedule < ActiveRecord::Base
  
  belongs_to :user
  
  Schedule.partial_updates = false
  serialize :courses
  serialize :colors
  serialize :quiz_sections
  serialize :labs
  
  COLORS = {1=>"ff6666",   2=>"ff66cc",  3=>"cc66ff",  4=>"6666ff",  5=>"66ccff",  6=>"66ffcc",  7=>"66ff66",  8=>"ccff66",  9=>"ffcc66", 10=>"ff6666",
            11=>"cc6666", 12=>"cc66cc", 13=>"6666cc", 14=>"66cccc", 15=>"66cc66", 16=>"cccc66", 17=>"cc6666", 18=>"666666", 19=>"9999cc", 20=>"ffcccc",
            21=>"cc0000", 22=>"336600", 23=>"003399", 24=>"cccccc", 25=>"cc9966", 26=>"99cc66", 27=>"66cc99", 28=>"6699cc", 29=>"9966cc", 30=>"cc6699",
            31=>"cccc66", 32=>"ff9966", 33=>"ffff66", 34=>"99ff66", 35=>"66ff99", 36=>"66ffff", 37=>"6699ff", 38=>"9966ff", 39=>"ff66ff", 40=>"ff6699"}
  
  def self.get_next_color(unavailable_colors)
    if(unavailable_colors==nil || unavailable_colors.size==0)
      return 1
    else
      max_val = unavailable_colors.sort.pop
      if(max_val < 40)
        return max_val+1
      else
        keys = COLORS.keys
        found = nil
        i= 0
        while(i<keys.size && found==nil)
          if(!unavailable_colors.include?(keys[i]))
            found = keys[i]
          end
          i = i + 1
        end
        if(found!=nil)
          return found
        else
          i=2
          while(found==nil)
            available = (keys*i) - unavailable_colors
            if(available!=nil && available.size>0)
              found = available[0]
            end
            i = i + 1
          end
          return found
        end
      end
    end
  end
  
  def self.authorized_to_view(schedule, curr_user)
    if(schedule.user_id==nil)
      return true
    end
    return schedule.user_id = curr_user.id
  end
  
  def self.authorized_to_edit(schedule, curr_user)
    if(schedule.user_id==nil)
      return true
    end
    return schedule.user_id = curr_user.id
  end
  
  def self.get_or_create_grab_bag(curr_user)
    attributes = {:user_id=>curr_user.id, :grab_bag=>true, :quarter=>Quarter::CURRENT, :year=>Time.now.year}
    schedule = Schedule.find(:first, :conditions => attributes)
    if(schedule==nil)
      schedule = Schedule.new(attributes)
      Schedule.create(schedule, {:schedule=>attributes}, curr_user)
      schedule.name = "#{curr_user.login}'s grab bag"
      schedule.courses = []
      schedule.colors = []
      schedule.quiz_sections = {}
      schedule.labs = {}
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
  
  def get_color_id_for_course(course)
    if(course!=nil)
      return self.colors[self.courses.index(course.id)]
    else
      return nil
    end
  end
  
  def get_color_for_course(course)
    if(course!=nil)
      return COLORS[get_color_id_for_course(course)]
    else
      return nil
    end
  end
  
  def self.add_to_schedule(schedule, course, curr_user, quiz_section=nil, lab=nil)
    if(schedule==nil)
      raise ScheduleError.new("No Schedule Given To Add To")
    end
    if(course==nil)
      raise ScheduleError.new("No Course Given To Add")
    end
    if(schedule.quarter!=course.quarter_id || schedule.year!=course.year)
      raise ScheduleError.new("Course And Schedule Differ in Quarter")
    end
    if(authorized_to_edit(schedule, curr_user))
      if(schedule.courses==nil)
        schedule.courses = []
      end
      if(schedule.colors==nil)
        schedule.colors = []
      end
      if(schedule.quiz_sections==nil)
        schedule.quiz_sections = {}
      end
      if(schedule.labs==nil)
        schedule.labs = {}
      end
      schedule.courses.push(course.id)
      if(schedule.grab_bag)
        while(schedule.colors.size < schedule.courses.size)
          schedule.colors.push(get_next_color(schedule.colors))
        end
      end
      if(quiz_section!=nil)
        schedule.quiz_sections[course.id] = quiz_section.id
      elsif(course.quiz_sections!=nil && course.quiz_sections.size>0)
        schedule.quiz_sections[course.id] = course.quiz_sections[0]
      end
      if(lab!=nil)
        schedule.labs[course.id] = lab.id
      elsif(course.labs!=nil && course.labs.size>0)
        schedule.labs[course.id] = course.labs[0]
      end
      if(schedule.save)
        return "Course Added Successfully"
      else
        return "Course Failed to be Added"
      end
    else
      return "User not Authorized to Edit This Schedule"
    end
  end
  
  def self.get_schedules(curr_user, options={})
    results = Schedule.find(:all, :conditions=>{:user_id=>curr_user.id, :grab_bag=>false})
    if(options[:create_on_none]!=nil && options[:create_on_none]==true && results.length<=0)
      attributes = {:user_id=>curr_user.id, :grab_bag => false, :courses=>[], :quarter => Quarter::CURRENT, :year => Time.now.year}
      schedule = Schedule.new(attributes)
      Schedule.create(schedule, {:schedule=>attributes}, curr_user)
      results = [schedule]
    end
    return results
  end
  
  def self.update_schedules(schedules, curr_user, options={})
    if(schedules==nil)
      raise ScheduleError.new("No schedules given to update")
    end
    if(curr_user==nil)
      raise ScheduleError.new("No user specified to use while updating schedules")
    end
    errors = [0,0,0]
    for key in schedules.keys
    begin sched = Schedule.find(key) rescue errors[1] += 1 end # Add to the schedule not found error count
      if(authorized_to_edit(sched, curr_user))
        begin
          if(schedules[key]['courses']!=nil)
            #for each id make it an int instead of a string
            schedules[key]['courses'].collect!{|elem| elem.to_i }
          end
          sched.update_attributes!(schedules[key])
        rescue
          errors[2] += 1 # Add to the general error count
        end
      else
        errors[0] += 1 # Add to the unauthorized error count
      end
    end
    ret = ""
    total_errors = errors[0] + errors[1] + errors[2]
    if(total_errors>0)
      ret += "#{total_errors} Schedules were not updated"
      if(errors[0]>0)
        ret += ", #{(errors[1]>0 || errors[2]>0)? errors[0] : ''} because you are not authorized to edit them"
      end
      if(errors[1]>0)
        ret += ", #{(errors[0]>0 || errors[2]>0)? errors[1] : ''} because the schedules specified were not found"
      end
      if(errors[2]>0)
        ret += ", #{(errors[0]>0 || errors[1]>0)? errors[2] : ''} because of an internal error"
      end
    end
  end
  
  def self.create(schedule, params, curr_user)
    if(schedule!=nil && params[:schedule]!=nil)
      schedule.user = curr_user
      courses = schedule.get_courses
      if(schedule.grab_bag==nil)
        schedule.grab_bag = 0
      end
      if(schedule.quarter==nil)
        if(courses!=nil && courses.size>0)
          schedule.quarter = courses[0].quarter_id
        else
          schedule.quarter = Quarter::CURRENT
        end
      end
      if(schedule.year==nil)
        if(courses!=nil && courses.size>0)
          schedule.year = courses[0].year
        else
          schedule.year = Quarter::CURRENT_YEAR
        end
      end
      if(schedule.rank==nil)
        schedule.rank = 1
      end
      if(schedule.courses==nil)
        schedule.courses = []
      end
      schedule.save!
      return "Schedule Created Successfully"
    else
      raise ScheduleError.new("Failed To Create Schedule")
    end
  end
  
  protected
  
  class ScheduleError < StandardError; end
  
end
