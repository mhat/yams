class JoinableController < ApplicationController
  
  
  
  # GET /joinables
  def index
    klass   = controller_to_model_class
    raise PermissionViolation unless klass.listable_by?(current_user)
    
    results = klass.find_all_by_owner_user_id(current_user).map{|j| j.to_rest}
    
    respond_to do |format|
      format.json { render :json => results }
    end
  end
  
  # GET /joinables/1
  def show
    klass    = controller_to_model_class
    joinable = klass.find(params[:id])
    raise PermissionViolation unless joinable.viewable_by?(current_user)
    
    members  = joinable.members.map{|user| user.to_rest }
    
        
    respond_to do |format|
      format.json do
        render :json => { 'joinable' => joinable.to_rest, 'members' => members }
      end
    end
  end
  
  # POST /joinables
  def create 
    klass    = controller_to_model_class
    raise PermissionViolation unless klass.creatable_by?(current_user)
    
    joinable = klass.create
    joinable.public = true
    joinable.owner  = current_user
    joinable.save!
    
    respond_to do |format|
      format.json { render :json => [joinable.to_rest] }
    end
  end
  
  # DELETE /joinables
  def destroy 
    klass    = controller_to_model_class
    joinable = current_user.joinable_by_class(klass).find(params[:id])
    raise PermissionViolation unless joinable.destroyable_by?(current_user)
    
    joinable.delete
    
    respond_to do |format|
      format.json { render :json => [{'status' => 'ok'}] }
    end
  end
  
  
  
  private
  def controller_to_model_class
    return Event   if self.class == EventsController
    return Group   if self.class == GroupsController
    return Project if self.class == ProjectsController
  
    return nil
  end
end