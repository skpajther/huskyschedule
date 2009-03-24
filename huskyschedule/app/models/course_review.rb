class CourseReview < ActiveRecord::Base
  
  RATING_VERYPOOR = 1
  RATING_POOR = 2
  RATING_AVERAGE = 3
  RATING_GOOD = 4
  RATING_EXCELLENT = 5
  
  RATING_TYPES = [
    # Displayed        stored in db
    [ "Very Poor",      RATING_VERYPOOR ],
    [ "Poor",           RATING_POOR ],
    [ "Average",        RATING_AVERAGE ],
    [ "Good",           RATING_GOOD ],
    [ "Excellent",      RATING_EXCELLENT]
  ]
  
  belongs_to :teacher
  belongs_to :quarter
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  
  def self.create(course_review, course, params, curr_user)
    if(course_review!=nil && params[:course_review]!=nil && course!=nil)
      course_review.course_name = course.name
      course_review.teacher_id = course.teacher_id
      course_review.save!
      message = "Course Rating Created Successfully"
      CourseReview.recalculate_review_info(course, course_review)
    else
      message = "Course Rating Failed to be Created"
    end
    return message
  end
  
  #TODO fix so that all courses with the same name are updated
  def self.recalculate_review_info(course, new_review=nil)
    if(course.rating == nil)
      course.rating = 0
    end
    if(course.total_ratings == nil)
      course.total_ratings = 0
    end
    if(new_review!=nil)
      rating_tot = course.rating * course.total_ratings
      rating_tot += new_review.rating
      course.total_ratings += 1
      course.rating = (rating_tot*1.0)/course.total_ratings
    else
      reviews = CourseReview.find_all_by_course_name(course.name)
      rating_tot = 0
      tot_ratings = 0
      for review in reviews
        rating_tot += review.rating
        tot_ratings += 1
      end
      course.rating = (rating_tot*1.0)/tot_ratings
      course.total_ratings = tot_ratings
    end
    course.save
  end
  
  class CourseReviewError <StandardError; end
  
end
