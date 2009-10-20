class SearchController < ApplicationController
  
  def index
    if(params[:search_text]!=nil)
      @courses = Course.find_by_search_text(params[:search_text], :limit=>2)
      @teachers = Teacher.find_by_search_text(params[:search_text], :limit=>2)
      @search_text = params[:search_text]
    end
  end

end
