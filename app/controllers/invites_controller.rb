class InvitesController < ApplicationController
  
  # GET /invites
  #   returns an +array+ of all matching invites for the +current_user+ 
  #
  # parameters
  # * kind[]   = one or both of <sent,received>
  # * type[]   = one or more of <event,group,project>
  # * status[] = one or more of <pending,accepted,ignored>
  
  def index
    raise PermissionViolation unless User.listable_by?(current_user)
    
    response = []
    [:kind, :type, :status].each { |sym| params[sym] = YAMS::Util.arrayify(params[sym]) }
    
    # FIXME: Invite.search doesn't do anything interesting with user
    # provided data,  i'd like to have a library to canonicalize and 
    # sanitize user provided dat. 
    #
    response = Invite.search \
      :from   => params[:kind].select{|v| v.downcase == 'sent'    }.empty?? nil : current_user,
      :to     => params[:kind].select{|v| v.downcase == 'received'}.empty?? nil : current_user,
      :types  => params[:type], 
      :status => params[:status] ## FIXME: Why no Status in Searches? 
    
    respond_to do |format|
      format.json { render :json => response }
    end
  end
  
  # GET /invites/:id
  #   returns an array with the requested invite iff the +current_user+ is
  #   the sender or recpient of the invitation.
  def show
    raise PermissionViolation unless current_user.viewable?(current_user)
    
    response = []
    response.concat current_user.sent_invites.find_all_by_id(params[:id])
    response.concat current_user.received_invites.find_all_by_id(params[:id])
    
    respond_to do |format|
      format.json { render :json => response }
    end
  end
  
  
  # PUT /invites/1
  #   update the status of an invite received by _current_user_
  #
  # parameters
  #   status, one of <accepted, ignored>
  #
  def update
    invite = current_user.received_invites.find(params[:id])
    raise PermissionViolation unless current_user.updateable?(current_user)
    
    case params[:status].downcase
      when 'accepted' then invite.accept!
      when 'ignored'  then invite.ignore!
    end
    
    respond_to do |format|
      format.json { render :json => invite }
    end
  end
  
  # POST /invites
  #   send an invite to a user for an _invitable_ provided that you are a
  #   member of that invitable
  #
  # paramers
  #   * note, optional
  #   * invitee_user_id, required 
  #   * invitable_type, one of <event, group_id, project_id> is required
  #   * invitable_id, id of some invitable
  # 
  def create
    raise PermissionViolation unless User.creatable_by?(current_user)
    
    target_user = User.find(params[:invitee_user_id])
    invitable   = case params[:invitable_type].downcase
      when 'event'   then Event.find(params[:invitable_id])
      when 'group'   then Group.find(params[:invitable_id])
      when 'project' then Project.find(params[:invitable_id])
    end
    
    invite = Invite.send!(current_user, target_user, '', invitable)
    
    respond_to do |format|
      format.json { render :json => invite }
    end
  end
  
  # DELETE /invites
  #   delete an invite, only possible if the current user created the invite
  def destroy
    raise PermissionViolation unless User.destroyable_by?(current_user)
    
    invite = current_user.sent_invites.find(params[:invite_id])
    invite.delete
    
    respond_to do |format|
      format.json do
      end
    end
  end
  
end
