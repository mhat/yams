class Invite < ActiveRecord::Base
  
  ## constants
  module Status
    PENDING  = 0
    ACCEPTED = 1
    IGNORED  = 2
  end
  
  ## permissions
  has_restful_permissions
  
  ## associations
  belongs_to :invitable, :polymorphic => true
  belongs_to :invitee,   :class_name  => "User", :foreign_key => 'invitee_user_id'
  belongs_to :inviter,   :class_name  => "User", :foreign_key => 'inviter_user_id'
  
  ## validations 
  validates_associated      :invitee, :inviter, :invitable
  validates_length_of       :note,    :maximum      => 255
  validates_numericality_of :status,  :only_integer => true
  validates_inclusion_of    :status,  :in           => 0..2
  
  
  ## instance methods 
  
  # Set status to +ignored+ and if this +Invite+ has previously been accepted
  # the invitee +User+ will be removed from Invitable.
  #
  def ignore!()
    self.status = Invite::Status::IGNORED
    invitable.remove_member invitee
    save!
  end
  
  # Sets status to +accepted+ and adds the invitee +User+ to the Invitable.
  #
  def accept!()
    self.status = Invite::Status::ACCEPTED
    invitable.add_member invitee
    save!
  end
  
  # Convince method to determin of the +User+ is the invitee. Rather than
  # saying:: invite.invitee == user, you can say invite.invitee? user, if
  # that sounds better to you.
  #
  def invitee?(user)
    return user.id == invitee_user_id
  end
  
  # Convince method to determin of the +User+ is the inviter. Rather than
  # saying:: invite.inviter == user, you can say invite.inviter? user, if
  # that sounds better to you.
  #
  def inviter?(user)
    return user.id == inviter_user_id
  end
  
  # Permissions: if the actor is the invitee, they may update the invite
  def updatable_by?(actor)
    return true if actor == invitee
    return false
  end
  
  # Premissions: if the actor is the inviter, they may delete the invite
  def destroyable_by?(actor)
    return true if actor == inviter
    return false
  end
  
  # Returns a sanitized hash of this +Invite. There's nothing to sanitize
  # in +Invite right now so this method returns all attributes.
  def to_rest
    return attributes
  end
  
  
  
  ## class methods
  
  # Syntatic shortcut to create! Returns a freshly created +Invite+ or a
  # piping hot exception for your exceptional pleasure.
  # 
  def self.send! (from_user, to_user, note, invitable)
    raise ArgumentError if from_user == to_user
    
    return Invite.create! do |invite|
      invite.inviter   = from_user
      invite.invitee   = to_user
      invite.note      = note
      invite.invitable = invitable
    end
  end
  
  
  
  # Handy search builder using on EZ::Where! Specifically this provides an
  # easy way to construct queries of the form: 
  #     (From    OR To                ) AND
  #     (Event   OR Group   OR Project) AND
  #     (Pending OR Ignored OR Active )
  # This is accomplished simply by passing any of the following parameters:
  # * :from     => +User+ 
  # * :to       => +User+
  # * :types    => +Array+ with zero or more of the values Event, Group or Project
  # * :statuses => +Array+ with zero or more of the values Pending, Ignored, or Active
  #
  def self.search (params={})
    from     = params[:from]     || nil
    to       = params[:to]       || nil
    types    = params[:types]    || []
    statuses = params[:statuses] || []
    
    
    conditions = EZ::Where::Condition.new :invites do
      
      ## filter: sender and receiver
      any do 
        inviter_user_id == from.id if from
        invitee_user_id == to.id   if to
      end
      
      ## filter: type of invitable
      any do
        types.each do |arg|
          case arg.downcase
          when 'event'   then invitable_type == 'Event'
          when 'group'   then invitable_type == 'Group'
          when 'project' then invitable_type == 'Project'
          end
        end
      end
      
      ## filter: invitation status
      status_list = []
      statuses.each do |arg|
        case arg.downcase
        when 'pending'  then status_list.push Invite::Status::PENDING
        when 'ignored'  then status_list.push Invite::Status::IGNORED
        when 'accepted' then status_list.push Invite::Status::ACCEPTED
        end
      end
      
      ## build the filter, yo.
      status === status_list
      
    end
    
    return Invite.find(:all, :conditions => conditions )
  end
  
end

