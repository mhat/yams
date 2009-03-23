class Invite < ActiveRecord::Base
  # constants
  module Status
    PENDING  = 0
    ACCEPTED = 1
    IGNORED  = 2
  end
  
  ## associations
  belongs_to :invitable, :polymorphic => true
  belongs_to :invitee, :class_name => "User", :foreign_key => 'invitee_user_id'
  belongs_to :inviter, :class_name => "User", :foreign_key => 'inviter_user_id'
  
  ## validators 
  validates_associated      :invitee, :inviter, :invitable
  validates_length_of       :note,    :maximum      => 255
  validates_numericality_of :status,  :only_integer => true
  validates_inclusion_of    :status,  :in           => 0..2
  
  
  ## instance methods 
  
  # set the status to _ignored_
  #
  def ignore!()
    self.status = Invite::Status::IGNORED
    save!
  end
  
  # set the status to _accepted_ and adds +User+ to _memberable_
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
  def invitee? (user)
    return user.id == invitee_user_id
  end
  
  # Convince method to determin of the +User+ is the inviter. Rather than
  # saying:: invite.inviter == user, you can say invite.inviter? user, if
  # that sounds better to you.
  #
  def inviter? (user)
    return user.id == inviter_user_id
  end
  
  
  
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
  
  
  
  
  ## class methods
  def self.send! (from_user, to_user, note, invitable)
    raise ArgumentError if from_user == to_user
    
    return Invite.create! do |invite|
      invite.inviter   = from_user
      invite.invitee   = to_user
      invite.note      = note
      invite.invitable = invitable
    end
  end
end

