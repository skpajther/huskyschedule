class CategoriesController < ApplicationController
  
  def index
    if(params[:id]!=nil)
      @category = Category.find(params[:id])
      curr = @category
      @familypath = []
      @familypath.push(curr)
      while curr.parent!=nil
        @familypath.push(curr.parent)
        curr = curr.parent
      end
      @courses = @category.courses
      @test_schedule = [[Time.parse("September 22, 2008 8:00"), Time.parse("September 22, 2008 11:00")],[Time.parse("September 22, 2008 11:00"), Time.parse("September 22, 2008 16:00")],[Time.parse("September 26, 2008 13:00"), Time.parse("September 26, 2008 18:00")]]
    end
  end
  
end
