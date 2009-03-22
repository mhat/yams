# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '601406ea5aec96a2c045c3db36853eda'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  before_filter :authenticate
  
  protected
  def authenticate
    authenticate_or_request_with_http_basic("YAMS-REST-API") do |username,password|
      logger.debug("u=#{username} p=#{password}")
      User.authenticate(username, password)
    end
  end
end
