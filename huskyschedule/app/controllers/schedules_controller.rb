class SchedulesController < ApplicationController
  
  def default_redirect
    return {:controller=>"schedules", :action=>"index"}
  end
  
  def index
    @grab_bag = Schedule.get_or_create_grab_bag(current_user)
    @schedules = Schedule.get_schedules(current_user, {:create_on_none => true})
    @dependancies = {}
    courses = @grab_bag.get_courses
    quiz_sections = []
    for course in courses
      for qz in course.quiz_sections
        quiz_sections << qz
      end
    end
    labs = []
    for course in courses
      for lab in course.labs
        labs << lab
      end
    end
    courses = courses + quiz_sections
    courses = courses + labs
    for course in courses
      course_id = course.id
      if(course.kind_of?(QuizSection))
        course_id = "qz_"+course.id.to_s
      elsif(course.kind_of?(Lab))
        course_id = "lab_"+course.id.to_s
      end
      if(@dependancies[course_id] == nil)
        @dependancies[course_id] = {}
      end
      list = @dependancies[course_id]
      for course2 in courses
        if(!((course.kind_of?(QuizSection) && course2.kind_of?(Course) && course.parent_id == course2.id) || (course2.kind_of?(QuizSection) && course.kind_of?(Course) && course2.parent_id == course.id) || (course.kind_of?(QuizSection) && course2.kind_of?(QuizSection) && course.parent_id == course2.parent_id) || (course.kind_of?(Lab) && course2.kind_of?(Course) && course.parent_id == course2.id) || (course2.kind_of?(Lab) && course.kind_of?(Course) && course2.parent_id == course.id) || (course.kind_of?(Lab) && course2.kind_of?(Lab) && course.parent_id == course2.parent_id)))
          course2_id = course2.id
          if(course2.kind_of?(QuizSection))
            course2_id = "qz_"+course2.id.to_s
          elsif(course2.kind_of?(Lab))
            course2_id = "lab_"+course2.id.to_s
          end
          if(course2!=course && list[course2_id]==nil)
            list[course2_id] = Course.compatible(course, course2)
            if(@dependancies[course2_id]==nil)
              @dependancies[course2_id] = {}
            end
            list_tmp = @dependancies[course2_id]
            list_tmp[course_id] = list[course2_id]
          end
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
        rescue Schedule::ScheduleError
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
        rescue Schedule::ScheduleError => error
          @result = error.to_s
          render :text=>@result, :status=>403
          return
        end  
      else
        @result = "Failed to Update Schedules"
        render :text=>@result, :status=>403
        return 
      end
    else
      redirect_back_or default_redirect
    end
  end
  
  def new
    if(params[:ajax]!=nil && params[:ajax]=="true")
      if(params[:schedule]!=nil)
        begin
          schedule = Schedule.new(params[:schedule])
          @result = Schedule.create(schedule, params, current_user)
          @result = schedule.id.to_s+","+((schedule.name!=nil)? schedule.name : "Unamed Schedule")+","+@result
        rescue Schedule::ScheduleError => error
          @result = "Failed to Create Schedule: "+error.to_s
          render :text=>@result, :status=>403
          return
        end  
      else
        @result = "Failed to Create Schedule: No parameters specified for schedule."
        render :text=>@result, :status=>403
        return
      end
    else
      redirect_back_or default_redirect
    end
  end
  
  def delete
    if(params[:ajax]!=nil && params[:ajax]=="true")
      if(params[:id]!=nil)
        #begin
          schedule = Schedule.find(params[:id])
          @result = Schedule.delete(schedule, current_user)
          render :text=>@result
          return
        #rescue Schedule::ScheduleError
          #@result = "Failed to Create Schedule"
          #render :text=>@result, :status=>403
          #return
        #end  
      else
        @result = "Failed to Delete Schedule"
        render :text=>@result, :status=>403
        return
      end
    else
      redirect_back_or default_redirect
    end
  end
  
end
