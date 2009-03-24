class UsersController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        response = []
        response = User.search_by_partial_screen_name(params[:query]).map{|user| user.to_rest} \
          if params[:query] && params[:query].length > 2
        
        render :json => response
      end
    end
  end
  
  # returns a hash with the current user
  def show
    respond_to do |format|
      format.json { render :json => current_user.to_rest }
    end
  end
end
