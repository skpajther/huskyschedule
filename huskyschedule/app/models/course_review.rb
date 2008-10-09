class CourseReview < ActiveRecord::Base
  
  RATING_VERYPOOR = 1
  RATING_POOR = 2
  RATING_AVERAGE = 3
  RATING_GOOD = 4
  RATING_EXCELLENT = 4
  
  RATING_TYPES = [
    # Displayed        stored in db
    [ "Very Poor",      RATING_VERYPOOR ],
    [ "Poor",          RATING_POOR ],
    [ "Average",        RATING_AVERAGE ],
    [ "Good",           RATING_GOOD ],
    [ "Excellent",      RATING_EXCELLENT]
  ]
  
  has_one :teacher
  belongs_to :quarter
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  
  
  def self.create(course_review, course, params, curr_user)
    if(course_review!=nil && params[:course_review]!=nil && course!=nil)
      course_review.course_name = "#{course.deptabriev} #{course.number}"
      course_review.save!
      return "Course Rating Created Successfully"
    end
    return "Course Rating Failed to be Created"
  end
  
  class CourseReviewError <StandardError; end
  
end
