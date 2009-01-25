class TeachersController < ApplicationController
  def index
    @teacher = Teacher.find(params[:id])
    
  end
  
  def vote
    if(logged_in? && params[:id]!=nil && params[:location]!=nil)
      @teacher = Teacher.find(params[:id])
      Teacher.vote_for_photo(@teacher, params[:location], current_user)
    end
    if(params[:next_page]!=nil)
      redirect_to params[:next_page]
    else
      redirect_to :controller=>"categories", :action=>"index" 
    end
  end
  
  def all_photos
    @teacher = Teacher.find(params[:id])
    if(request.post?)
      if(logged_in?)
        message = Teacher.upload_photo(@teacher, params[:upload], current_user)
      else
        message = "You Have to be logged in to upload photos."
      end
      flash[:notice] = message
      redirect_to(:controller=>"teachers", :action=>"index", :id=>@teacher.id)
    end
  end

end
