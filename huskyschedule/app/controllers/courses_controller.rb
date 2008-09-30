class CoursesController < ApplicationController
  
  def index
    @course = Course.find(params[:id])
    #@course.times = [[Time.parse("September 22, 2008 8:00"), Time.parse("September 22, 2008 11:00")],[Time.parse("September 22, 2008 11:00"), Time.parse("September 22, 2008 16:00")],[Time.parse("September 26, 2008 13:00"), Time.parse("September 26, 2008 18:00")]]
    #@course.save
  end
  
end
