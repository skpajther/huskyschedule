# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    # Be sure to include AuthenticationSystem in Application Controller instead
    include AuthenticatedSystem
    # If you want "remember me" functionality, add this before_filter to Application Controller
    before_filter :login_from_cookie
    
    include ImageSpec
  
    helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e952dc8a637fd488e61bb4eae8007246'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  before_filter :validate_access
  
  def validate_access
    if logged_in?
      #check is done continue
    else
      self.current_user = User.create(:login=>request.remote_ip, :email => request.remote_ip, :tmp_user => true, :last_used => Time.now.utc)
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
  end
  
  def redirect_back_or(path)
    redirect_to :back
    rescue ActionController::RedirectBackError
    redirect_to path
  end
  
  def help
    Helper.instance
  end
  
  class Helper
    include Singleton
    include ApplicationHelper
  end
  
end
