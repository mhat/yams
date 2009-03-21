module YAMS::Inviteable
  
  # Ensure that _Inviteable_ models implement methed:: public
  #
  def public
    raise NoMethodError, "implementation missing for method: public"
  end
  
  # Ensure that _Inviteable_ models implement method:: owner
  #
  def owner
    raise NoMethodError, "implementation missing for method: owner"
  end
  
  # Convince method to determine if this _Inviteable_ is public
  #
  def public?
    self.public
  end
  
  # Convince method to determin if +User+ has been invited to this _Inviteable_
  # by someone already. 
  #
  def has_invite?(user)
    invites.exists?(user)
  end
  
  # Creates an +Invite+ from one +User+ to another +User+ with an option note,
  # tihs is simply a wrapper to Invite.send! to make it more natural to invite
  # users to this _Inviteable_.
  #
  def invite!(user_from, user_to, note="")
    Invite.send!(user_from, user_to, note, self)
  end
  
  # Defines associations for _Inviteable_ models.
  # * owner:: returns the +User+ that ownes 
  # * invites:: returns all +Invite's+
  # * pending_invites:: returns only pending +Invite's+
  # * accepted_invites:: returns only accepted +Invite's+
  # * ignored_invites:: returns only ignored +Invite's+
  #
  def self.included(base)
    base.class_eval do
      belongs_to  :owner, :class_name => "User", :foreign_key => 'owner_user_id'
      
      has_many    :invites,          :as => :invitable
      has_many    :pending_invites,  :as => :invitable, :class_name => "Invite", :conditions => { :status => Invite::Status::PENDING  }
      has_many    :accepted_invites, :as => :invitable, :class_name => "Invite", :conditions => { :status => Invite::Status::ACCEPTED }
      has_many    :ignored_invites,  :as => :invitable, :class_name => "Invite", :conditions => { :status => Invite::Status::IGNORED  }
    end
  end
end