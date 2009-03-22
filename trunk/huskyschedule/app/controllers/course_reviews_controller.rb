class CourseReviewsController < ApplicationController
  
  def index
    @course = Course.find(params[:id])
    @by_rating = false;
    if(!params[:rating_val].nil?)
      @rating_val = params[:rating_val]
      if(@rating_val > CourseReview::RATING_EXCELLENT || @rating_val < CourseReview::VERYPOOR)
        @rating_val = "All"
      else
        @by_rating = true
      end
    end
    @by_teacher = false
    if(!params[:teacher_id].nil?)
      teacher = Teacher.find(params[:teacher_id])
      if(!teacher.nil?)
        @by_teacher = true
      end
    end
    @count_ratings = [0,0,0,0,0]
    if(@by_teacher)
      @course_reviews = CourseReview.find(:all, :conditions => {:course_name=>@course.name, :teacher_id=>params[:teacher_id]})
    else
      @course_reviews = CourseReview.find(:all, :conditions=>{:course_name=>@course.name})
    end
    for review in @course_reviews
      @count_ratings[review.rating-1] += 1
    end
    @teachers = []
    #need counts for all the teachers, i reccommend building a hash od <teacher id, count>
    #TODO Dan finish this
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
