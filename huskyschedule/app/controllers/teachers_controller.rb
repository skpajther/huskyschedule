class TeachersController < ApplicationController
  
  def default_redirect
    return {:controller=>"categories", :action=>"index"}
  end
  
  def index
    @teacher = Teacher.find(params[:id])
    @teacher_info_index = 0
    if(params[:teacher_info_index]!=nil)
      @teacher_info_index = params[:teacher_info_index].to_i
    end
    if(params[:teacher_info_id]!=nil)
      #@teacher_info_index = TeacherInfo.get_techer_info_index(params[:teacher_info_id])
      begin @teacher_info = TeacherInfo.find(params[:teacher_info_id].to_i) rescue @teacher_info = nil end
      @teacher_info_index = TeacherInfo.count_by_sql("SELECT count(ti2.id) FROM teacher_infos ti1, teacher_infos ti2 WHERE ti1.id = #{params[:teacher_info_id].to_i} AND ti2.teacher_id = ti1.teacher_id AND (ti2.total_confirmations > ti1.total_confirmations OR (ti2.total_confirmations=ti1.total_confirmations AND ti2.id > ti1.id))")
      if(@teacher_info_index!=nil && @teacher_info_index!="")
        @teacher_info_index = @teacher_info_index[0].to_i
      else
        @teacher_info_index = 0
      end
    end
    @total_infos = TeacherInfo.count_by_sql("SELECT COUNT(*) FROM teacher_infos WHERE teacher_id=#{@teacher.id}")
    if(@teacher_info_index >= @total_infos)
      @teacher_info_index = 0
    elsif(@teacher_info_index < 0)
      @teacher_info_index = @total_infos-1
    end
    if(@teacher_info==nil)
      @teacher_info = @teacher.teacher_info_at_index(@teacher_info_index)
    end
    if(params[:render] == "user_supplied_info")
      render :partial => "teachers/user_supplied_info", :locals => {:info=>@teacher_info, :teacher=>@teacher, :teacher_info_index=>@teacher_info_index, :curr_user=>current_user}
    end
  end
  
  def confirm_user_info
    begin teacher_info = TeacherInfo.find(params[:id]) rescue teacher_info = nil end
    if(teacher_info!=nil)
      begin
        TeacherInfo.confirm(teacher_info, current_user)
        if(params[:nextpage]!=nil)
          #flash[:notice] = success_messages
          redirect_to(params[:nextpage])
          return
        end
      rescue ActiveRecord::RecordInvalid
        #do nothing just continue, when the view renders it will see the errors on @comment 
      rescue TeacherInfo::TeacherInfoError => error
        flash[:notice] = error.to_s
      end
    end
    render :partial=>"teachers/blank", :locals=>{}
  end
  
  def new_user_info
    TeacherInfo.fix_blanks(params[:teacher_info])
    begin user_info = TeacherInfo.new(params[:teacher_info]) rescue user_info = nil end
    begin teacher = Teacher.find(params[:id]) rescue teacher=nil end
    if(user_info!=nil && request.post?)
      begin
        success_messages = TeacherInfo.create(user_info, teacher, params, current_user)
        if(params[:nextpage]!=nil)
          flash[:notice] = success_messages
          redirect_to(params[:nextpage])
          return
        end
      rescue ActiveRecord::RecordInvalid
        #do nothing just continue, when the view renders it will see the errors on @comment 
      rescue TeacherInfo::TeacherInfoError => error
        flash[:notice] = error.to_s
      end
    end
    if(flash[:notice]==nil)
      flash.now[:notice] = "Failed to create comment"
    end
    @teacher = teacher
    @info = user_info
    @teacher_info_index = -1
    if(params[:teacher_info_index]!=nil)
      @teacher_info_index = params[:teacher_info_index]
    end
    render :partial => "teachers/create_or_edit_user_supp_info", :locals => {:info=>@info, :teacher=>@teacher, :teacher_info_index=>@teacher_info_index.to_i, :render=>"new_user_info", :curr_user=>current_user} 
  end
  
  def edit_user_info
    begin user_info = TeacherInfo.find(params[:id]) rescue user_info = nil end
    if(user_info!=nil && request.post?)
      begin
        success_messages = TeacherInfo.update(user_info, params, current_user)
        if(params[:nextpage]!=nil)
          flash[:notice] = success_messages
          redirect_to(params[:nextpage])
          return
        end
        flash.now[:notice] = success_messages
      rescue ActiveRecord::RecordInvalid
        #do nothing just continue, when the view renders it will see the errors on @account
      rescue TeacherInfo::TeacherInfoError => error
        flash.now[:notice] = error.to_s
      end
    end
    @info = user_info
    render :partial=>"teachers/blank", :locals=>{}#render :partial => "teachers/user_supplied_info", :locals => {:info=>@info, :teacher=>@info.teacher, :render=>"edit_user_info", :teacher_info_index=>params[:teacher_info_index]}
  end
  
  def destroy_user_info
    begin user_info = TeacherInfo.find(params[:id]) rescue user_info = nil end
    if(user_info!=nil)
      begin
        user_info.destroy
        if(params[:nextpage]!=nil)
          #flash[:notice] = success_messages
          redirect_to(params[:nextpage])
          return
        elsif(params[:user_info_switch]!=nil)
          index(params[:user_info_switch])
        end
        #flash.now[:notice] = success_messages
      rescue ActiveRecord::RecordInvalid
        #do nothing just continue, when the view renders it will see the errors on @account
      rescue TeacherInfo::TeacherInfoError => error
        flash.now[:notice] = error.to_s
      end
    end
    redirect_to default_redirect
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
