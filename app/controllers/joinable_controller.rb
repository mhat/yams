class JoinableController < ApplicationController
  
  
  
  # GET /events
  #   return an array of inviteables that the current_user either owns or is
  #   a member of!
  #
  def index
    klass   = controller_to_model_class
    results = klass.find_all_by_owner_user_id(current_user)
    
    respond_to do |format|
      format.json { render :json => results }
    end
  end
  
  # GET /events/1
  def show
    klass    = controller_to_model_class
    joinable = klass.find(params[:id])
    
    ## only show event details if the following criteria are met
    raise ActiveRecord::RecordNotFound unless joinable.public? \
      || joinable.owner?(current_user)      \
      || joinable.has_member?(current_user) \
      || joinable.has_invite?(current_user) 
    
    ## collect and rest-ify the members of this joinable
    members  = joinable.members.map{|user| user.to_rest }
    
    respond_to do |format|
      format.json do
        render :json => { 'joinable' => joinable, 'members' => members }
      end
    end
  end
  
  # POST /events
  def create 
    klass    = controller_to_model_class
    joinable = klass.create
    joinable.public = true
    joinable.owner  = current_user
    joinable.save!
    
    render :json => joinable
  end
  
  # DELETE /events
  def destroy 
    klass    = controller_to_model_class
    joinable = current_user.joinable_by_class(klass).find(params[:id])
    joinable.delete
    
    respond_to do |format|
      format.json { render :json => [{'status' => 'ok'}] }
    end
  end
  
  
  
  
  private
  def controller_to_model_class
    return Event   if self.class == EventsController
    return Group   if self.class == GroupsController
    return Project if self.class == ProjectController
  
    return nil
  end
end