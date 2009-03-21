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
    status = Invite::Status::IGNORED
    save!
  end
  
  # set the status to _accepted_.
  #
  def accept!()
    status = Invite::Status::ACCEPTED
    inviteable.add invitee
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
  
  ## class methods
  def self.send! (from_user, to_user, note, invitable)
    return Invite.create! do |invite|
      invite.inviter   = from_user
      invite.invitee   = to_user
      invite.note      = note
      invite.invitable = invitable
    end
  end
end

