class TeacherInfo < ActiveRecord::Base
  
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  belongs_to :teacher, :class_name => "Teacher", :foreign_key => "teacher_id"
  
  TeacherInfo.partial_updates = false
  serialize :other
  serialize :confirmed_by
  
  def self.authorized_to_edit(curr_user, teacher_info)
    return !curr_user.tmp_user && teacher_info.user_id == curr_user.id # || curr_user.su
  end
  
  def self.create(teacher_info, teacher, params, curr_user)
    if(teacher_info!=nil && params[:teacher_info]!=nil && teacher!=nil && curr_user!=nil && !curr_user.tmp_user)
      teacher_info.author = curr_user
      teacher_info.teacher = teacher
      teacher_info.total_confirmations = 0
      teacher_info.save!
      message = "Teacher Information Created Successfully"
    else
      message = "Teacher Information Failed to be Created"
    end
    return message
  end
  
  def self.update(teacher_info, params, curr_user)
    if(params[:teacher_info]!=nil && TeacherInfo.authorized_to_edit(curr_user, teacher_info))
      fix_blanks(params[:teacher_info])
      teacher_info.total_confirmations = 0
      teacher_info.confirmed_by = {}
      teacher_info.update_attributes!(params[:teacher_info])
    else 
      raise TeacherInfoError.new("You are not authorized to edit this teacher information")
    end
    return "Teacher Information updated Successfully"
  end
  
  def self.confirm(teacher_info, curr_user)
    if(teacher_info!=nil && curr_user!=nil && !curr_user.tmp_user)
      if(teacher_info.confirmed_by==nil)
        teacher_info.confirmed_by = {}
      end
      if(teacher_info.total_confirmations==nil)
        teacher_info.total_confirmations = 0
      end
      teacher_info.confirmed_by[curr_user.id] = true
      teacher_info.total_confirmations += 1
      teacher_info.save!
    end
  end
  
  def self.fix_blanks(teacher_info_hash)
    if(teacher_info_hash!=nil)
      for attri in teacher_info_hash.keys
        if(teacher_info_hash[attri]=="")
          teacher_info_hash[attri] = nil
        end
      end
    end
  end
  
  def self.is_author?(teacher, curr_user)
    tmp = TeacherInfo.find_by_sql("SELECT * FROM teacher_infos WHERE teacher_id=#{teacher.id} AND user_id=#{curr_user.id}")
    if(tmp.length <= 0)
      return nil
    end
    return tmp[0]
  end
  
  def self.already_confirmed(info, curr_user)
    if(info.confirmed_by!=nil)
      return info.confirmed_by[curr_user.id]!=nil
    end
    return false
  end
    
  class TeacherInfoError <StandardError; end

end
