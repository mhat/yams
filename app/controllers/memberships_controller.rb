class MembershipsController < ApplicationController
  
  # GET /memberships
  #   returns an +array+ of all matching _memberables_
  # 
  # parameters:
  # * type[] : one of <event, group, project>, stackable
  #
  def index
    response = []
    
    respond_to do |format|
      format.json do
        
        ## determine if a type was provided, if not try to grab everything
        params[:type] = ['event', 'group', 'project'] if !params[:type]
        
        [ params[:type] ].flatten.each do |type|
          case type.downcase
          when 'event'   then response << current_user.events
          when 'group'   then response << current_user.groups
          when 'project' then response << current_user.projects
          end
        end
        
        render :json => response.flatten
      end
    end
  end
  
  # POST /memberships
  #   allows the current_user to join a public event
  #
  # parameters
  #   id 
  def create
    joinable = case params[:type].downcase
    when 'event'   then Event.find(params[:id])
    when 'group'   then Group.find(params[:id])
    when 'project' then Project.find(params[:id])
    end
    
    joinable.add_member current_user if joinable.public?
    
    respond_to do |format|
      format.json do
        render :json => [{'status' => 'ok'}]
      end
    end
  end
  
  
  # DESTROY /memberships
  #   Allows the current_user to a) remove themselves from a joinable or b)
  #   remove a user from a joinable that the current_user ownes.
  #
  # parameters:
  # * <type>_id : required, one of event, type or project
  # * member_id : required, the id of the user to remove
  #
  def destroy
    status   = []
    member   = User.find(params[:member_id])
    joinable = case params[:type].downcase
    when 'event'   then Event.find(params[:id])
    when 'group'   then Group.find(params[:id])
    when 'project' then Project.find(params[:id])
    end
    
    if joinable.owner? current_user
      ## the current_user may only remove other-users from a joinable if
      ## they are the owner and they are not removing themselves.
      if member == current_user
        status = [{'message' => 'not allowed'}]
      else
        joinable.remove_member member
        status = [{'message' => 'success'}]
      end
      
    elsif joinable.has_member? member
      ## the current_user may only remove themselves from joinables that
      ## they are not the owner of
      if member != current_user
        status = [{'message' => 'not allowed'}]
      else
        joinable.remove_member member
        status = [{'message' => 'success'}]
      end
    end
    
    respond_to do |format|
      format.json { render :json => status }
    end
  end
  
end
