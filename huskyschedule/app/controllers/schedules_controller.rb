class SchedulesController < ApplicationController
  
  
  def index
    @grab_bag = Schedule.get_grab_bag(current_user)
    if(@grab_bag == nil)
      @grab_bag = Schedule.create(:user_id=>current_user.id, :courses=>[], :quarter=>Quarter::CURRENT, :year=>Time.now.year, :name=>"#{current_user.login}'s grab bag", :grab_bag=>true )
    end
  end
end
