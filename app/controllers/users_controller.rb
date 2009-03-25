class UsersController < ApplicationController
  
  ## note: see docs/api-rest.markdown for documentation
  
  
  # GET /users
  def index
    raise PermissionViolation unless User.listable_by?(current_user)
    
    response = []
    response = User.search_by_partial_screen_name(params[:query]).map{|user| user.to_rest} \
      if params[:query] && params[:query].length >= 2
    
    respond_to do |format|
      format.json { render :json => response }
    end
  end
  
  # GET /users/:id
  def show
    raise PermissionsViolation unless current_user.viewable_by?(current_user)
    
    respond_to do |format|
      format.json { render :json => current_user.to_rest }
    end
  end
  
end
