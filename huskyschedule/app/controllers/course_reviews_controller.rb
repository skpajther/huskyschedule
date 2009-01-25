class CourseReviewsController < ApplicationController
  
  def index
    @course = Course.find(params[:id])
    if(params[:rating_val]==nil || params[:rating_val].to_i > 5 || params[:rating_val].to_i < 1)
      @course_reviews = CourseReview.find_all_by_course_name(@course.name)
    else
      @course_reviews = CourseReview.find(:all, :conditions=>{:course_name=>@course.name, :rating=>params[:rating_val]})
    end
  end
  
  def new
    begin course_review = CourseReview.new(params[:course_review]) rescue course_review = nil end
    begin course = Course.find(params[:id]) rescue course=nil end
    if(course_review!=nil && request.post?)
      begin
        success_messages = CourseReview.create(course_review, course, params, current_user)
        if(params[:nextpage]!=nil)
          flash[:notice] = success_messages
          redirect_to(params[:nextpage])
          return
        end
      rescue ActiveRecord::RecordInvalid
        #do nothing just continue, when the view renders it will see the errors on @comment 
      rescue CourseReview::CourseReviewError => error
        flash[:notice] = error.to_s
      end
    end
    if(flash[:notice]==nil)
      flash.now[:notice] = "Failed to create comment"
    end
    @course = course
    @course_review = course_review
  end
  
  def edit
    
  end
  
end
