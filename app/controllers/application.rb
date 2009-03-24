# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  ## filters
  before_filter :dispose_user
  before_filter :authenticate
  
  # convince method available to all controllers
  def current_user
    User.current_user
  end
  
  
  def rescue_action (ex)
    respond_to do |format| 
      case ex
      when ActiveRecord::RecordNotFound then
        format.json { render :json => [{'status' => 404}]  }
      else
        ## handles any raised exception with a 500
        format.json { render :json => [{'status' => 500}]  }
      end
    end
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
