class CoursesController < ApplicationController
  
  def index
    @course = Course.find(params[:id])
    @other_lectures = Course.find(:all, :conditions => "id <> #{@course.id} AND quarter_id=#{@course.quarter_id} AND year=#{@course.year} AND deptabbrev='#{@course.deptabbrev}' AND number='#{@course.number}'")
    @quiz_sections = QuizSection.find_all_by_parent_id(@course.id, :order=>"section")
    @labs = Lab.find_all_by_parent_id(@course.id, :order=>"section")
    @course_reviews = CourseReview.find_all_by_course_name(@course.name, :limit=>3)
    @course.total_ratings = @course_reviews.length
    @course.save
  end
  
end
