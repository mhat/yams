# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  before_filter :dispose_user
  before_filter :authenticate
  
  # convince method available to views so you don't have to say User.current_user
  def current_user
    User.current_user
  end
  
  
  protected
  
  # make sure current_user isn't the user from the last request
  def dispose_user
    User.current_user = nil
  end
  
  def authenticate
    authenticate_or_request_with_http_basic("YAMS-REST-API") do |username,password|
      User.authenticate(username, password)
    end
  end
end
