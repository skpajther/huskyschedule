class CoursesController < ApplicationController
  
  def index
    @course = Course.find(params[:id])
    @other_lectures = Course.find(:all, :conditions => "id <> #{@course.id} AND quarter_id=#{@course.quarter_id} AND year=#{@course.year} AND deptabbrev='#{@course.deptabbrev}' AND number='#{@course.number}'")
    @joint_offerings = nil
    if(!(@course.additional_info.nil?) && @course.additional_info.include?(Course::ADDITIONALINFO_J))
      @joint_offerings = Course.find(:all, :conditions=>"id<>#{@course.id} AND title='#{@course.title}'")
    end
    @quiz_sections = QuizSection.find_all_by_parent_id(@course.id, :order=>"section")
    @labs = Lab.find_all_by_parent_id(@course.id, :order=>"section")
    #first find course reviews for this course/teacher
    @course_reviews = CourseReview.find(:all, :limit => 3, :conditions => "course_name = '#{@course.name}' AND teacher_id=#{@course.teacher_id}")
    if(@course_reviews.length < 3) #if not enough results, find all reviews for this course
      no_ids = ""
      for review in @course_reviews
        no_ids << " AND id<>#{review.id} "
      end
      others = CourseReview.find(:all, :limit => (3 - @course_reviews.length), :conditions => "course_name = '#{@course.name}' #{no_ids}")
      for review in others
        @course_reviews.push(review)
      end
    end
    if(@course.total_ratings.nil? || @course.rating.nil?)
      all_reviews = CourseReview.find_all_by_course_name(@course.name)
      @course.total_ratings = all_reviews.length
      if(all_reviews.length==0)
        @course.rating = 0
      else
        running_total = 0
        for review in all_reviews
          running_total += review.rating
        end
        @course.rating = running_total/all_reviews.length
      end
    end
    @teacher_reviews = TeacherReview.find_all_by_teacher_id(@course.teacher_id, :limit=>3)
  end
  
end
