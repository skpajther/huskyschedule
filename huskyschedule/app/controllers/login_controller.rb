class LoginController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    @next_page = params[:next_page]
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      if(params[:next_page]!=nil)
        redirect_to params[:next_page]
      else
        redirect_back_or_default(:controller => 'categories', :action => 'index')
      end
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @user = User.new(params[:user])
    @next_page = params[:next_page]
    return unless request.post?
    @user.save!
    self.current_user = @user
    flash[:notice] = "Thanks for signing up!"
    if(params[:next_page]!=nil)
      redirect_to params[:next_page]
    else
      redirect_back_or_default(:controller => 'categories', :action => 'index')
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    if(params[:next_page]!=nil)
      redirect_to params[:next_page]
    else
      redirect_back_or_default(:controller => 'categories', :action => 'index')
    end
  end
end
