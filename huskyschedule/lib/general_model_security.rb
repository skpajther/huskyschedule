module GeneralModelSecurity
  
  # This file is a mixin that should be used to enforce model security
  # on any of our core classes. Including it (like task.rb and project.rb do)
  # ensures that each model uses the same methods, not the base methods, to
  # save data.
   
  def save!(curr_user)
    if(self.class.authorized_to_edit(curr_user,self))
      before_saved(curr_user)# this is here instead of using the callback :before_save because the callback cannot supply the current_user
      super()
    else
      raise "User Not authorized to edit"
    end
  end  
    
  def save_changes(curr_user, validate=true)
    if(self.class.authorized_to_edit(curr_user,self))
      before_saved(curr_user)# this is here instead of using the callback :before_save because the callback cannot supply the current_user
      validate ? save : save(validate)
    else
      raise "User Not authorized to edit"
    end
  end
  
  def destroy(curr_user)
    if(self.class.authorized_to_edit(curr_user,self))
      super()
    else
      raise "User Not authorized to destroy"
    end
  end
  
  def update_attributes(attributes, curr_user)
    self.attributes = attributes
    save_changes(curr_user)
  end
  
  def update_attributes!(attributes, curr_user)
    self.attributes = attributes
    save!(curr_user)
  end
 
=begin   
  def account=(value)#,curr_user)
    if(self.account==nil)
      write_attribute("account_id",value.id)
      save
    else
      raise "Cannot change account"
    end
  end
=end

  def accept_reject(curr_user, accept=true)
    if(self.kind_of?(Task))
      if(Task.authorized_to_view(curr_user, self) && self.assignee==curr_user)
        self.accepted = accept
        save
      else
        raise "User not authorized to accept"
      end
    else
      raise "accept(curr_user) is only valid for tasks created from task.rb"
    end
  end
  
# TODO: Danny, please explain why these are here
 protected
 def save(validate=true)
   validate ? super : super(validate)
 end 
 
 def id=(value)
   super
 end
 
 def before_saved(curr_user)
    #stub method that can be overiden by classes that include this class
 end 
 
end