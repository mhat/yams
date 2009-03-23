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
  
  # DELETE /memberships
  #   remove a user from a list, to do so you must be the list owner
  # 
  # parameters:
  # * <type>_id : required, one of event, type or project
  # * member_id : required, the id of the user to remove
  #
  def delete
  end
  
end
