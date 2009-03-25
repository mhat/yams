class MembershipsController < ApplicationController
  
  # GET /memberships
  #   returns an +array+ of all matching _memberables_
  # 
  # parameters:
  # * type[] : one of <event, group, project>, stackable
  #
  def index
    ## FIXME: i *should* have a permission check here but it's not easy to do
    ## while joinable is a module mix-in rather than a class extending AR
    ## raise PermissionViolation unless ... 
    
    
    ## a little work to make sure we're only given valid types
    joinable_type = YAMS::Util.arrayify(params[:type]).select {
      |type|
      allowed_type_parameters.select { |atype| atype==type }
    }
    
    ## if no valid types were presented, use all of the defaults
    joinable_type = allowed_type_parameters if joinable_type.size == 0
    
    ## collect the joinables, e.g. events, groups & projects
    response = joinable_type.map { |type| 
      current_user.joinable_by_class(type_parameter_to_class(type))
    }.flatten.map { |joinable| joinable.to_rest }
    
    respond_to do |format|
      format.json { render :json => response }
    end
  end
  
  # POST /memberships
  #   allows the current_user to join a public event
  #
  # parameters
  #   id 
  #   type
  def create
    joinable = type_parameter_to_class(params[:type]).find(params[:id])
    
    raise PermissionViolation unless joinable.member_addable_by?(current_user)
    
    joinable.add_member current_user
    
    respond_to do |format|
      format.json { render :json => [{'status' => 'ok'}] }
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
    member   = User.find(params[:member_id])
    joinable = type_parameter_to_class(params[:type]).find(params[:id])
    
    raise PermissionViolation unless joinable.member_removeable_by?(member, current_user)
    
    joinable.remove_member member
    
    respond_to do |format|
      format.json { render :json => [{'status' => 'ok'}] }
    end
  end
  
  
  
  private 
  def allowed_type_parameters 
    return ['event', 'group', 'project']
  end
  
  def type_parameter_to_class (type)
    case type.downcase
    when 'event'   then return Event
    when 'group'   then return Group
    when 'project' then return Project
    else
      throw ArgumentError, "invalid type"
    end
  end
end
