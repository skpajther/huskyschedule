class SchedulesController < ApplicationController
  
  def default_redirect
    return {:controller=>"schedules", :action=>"index"}
  end
  
  def index
    @grab_bag = Schedule.get_or_create_grab_bag(current_user)
    @schedules = Schedule.get_schedules(current_user, {:create_on_none => true})
    @dependancies = {}
    courses = @grab_bag.get_courses
    for course in courses
      if(@dependancies[course.id] == nil)
        @dependancies[course.id] = {}
      end
      list = @dependancies[course.id]
      for course2 in courses
        if(course2!=course && list[course2.id]==nil)
          list[course2.id] = Course.compatible(course, course2)
          if(@dependancies[course2.id]==nil)
            @dependancies[course2.id] = {}
          end
          list_tmp = @dependancies[course2.id]
          list_tmp[course.id] = list[course2.id]
        end
      end
    end
  end
  
  def add_to_grab_bag
    if(params[:ajax]!=nil && params[:ajax]=="true")
      if(params[:course_id]!=nil)
        grab_bag = Schedule.get_or_create_grab_bag(current_user)
        course = Course.find(params[:course_id])
        begin
          @result = Schedule.add_to_schedule(grab_bag, course, current_user)
        rescue ScheduleError
          @result = "Failed to Add Course to Schedule"
        end
      else
        @result = "Failed to Add Course to Schedule"
      end
    else
      redirect_back_or default_redirect
    end
  end
  
  def save_schedules
    if(params[:ajax]!=nil && params[:ajax]=="true")
      if(params[:schedules]!=nil)
        begin
          @result = Schedule.update_schedules(params[:schedules], current_user)
        rescue Schedule::ScheduleError
          @result = "Failed to Update Schedules"
        end  
      else
        @result = "Failed to Update Schedules"  
      end
    else
      redirect_back_or default_redirect
    end
  end
  
  def new
    if(params[:ajax]!=nil && params[:ajax]=="true")
      if(params[:schedule]!=nil)
        #begin
          schedule = Schedule.new(params[:schedule])
          @result = Schedule.create(schedule, params, current_user)
          @result = schedule.id.to_s+","+((schedule.name!=nil)? schedule.name : "Unamed Schedule")+","+@result
        #rescue Schedule::ScheduleError
          #@result = "Failed to Create Schedule"
          #render :text=>@result, :status=>403
          #return
        #end  
      else
        @result = "Failed to Create Schedule"
        render :text=>@result, :status=>403
        return
      end
    else
      redirect_back_or default_redirect
    end
  end
  
end
