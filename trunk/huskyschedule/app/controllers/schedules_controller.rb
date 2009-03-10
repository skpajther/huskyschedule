class SchedulesController < ApplicationController
  
  
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
        #begin
          @result = Schedule.add_to_schedule(grab_bag, course)
        #rescue ScheduleError
          #@result = "Failed to Add Course to Schedule"
        #end
      else
        @result = "Failed to add Course to Schedule"
      end
    else
      redirect_to :back
    end
  end
end
