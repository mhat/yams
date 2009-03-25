module YAMS
  module Joinable
    
    ## instance methods
    
    # Convince method to determine if this _Joinable_ is public
    #
    def public?
      self.public
    end
    
    # Convince method to determine if the provided user is the owner of
    # this _Joinable_
    def owner? (user)
      user == owner
    end
    alias :is_owner? :owner?
    
    # Convince method to determin if +User+ has been invited to this _Joinable_
    # by someone already. 
    #
    def has_invite?(user)
      invites.exists?(user)
    end
    
    # Convince method to determine if +User+ is a member of this _Joinable_.
    #
    def has_member?(user)
      members.exists?(user)
    end
    
    # Convince method to add +User+ to this _Joinable. Nothing is done if the
    # if +User+ is already a memeber this _Joinable_.
    #
    def add_member(user)
      members << user unless has_member? user
    end
    
    # Convince method to remove +User+. Nothing is done if +User+ is not a 
    # membber of this _Joinable_.
    #
    def remove_member(user)
      members.delete user if has_member? user
    end
    
    # Creates an +Invite+ from one +User+ to another +User+ with an optional note.
    # This is simply a wrapper to Invite.send! to make sending invitations feel a 
    # little more natural. 
    #
    def invite!(user_from, user_to, note="")
      Invite.send!(user_from, user_to, note, self)
    end
    
    # Permissions: Determins if Actor is allowed to Remove member. An actor may
    # remove themselves from ANY joinable *provided* they are not the owner. An
    # actor may remove ANY user from a joinable *provided* they ARE the owner!
    #
    def member_removeable_by?(member, actor)
      return true if has_member?(member) && !is_owner?(actor)
      return true if has_member?(member) &&  is_owner?(actor) &&  actor != member
      return false
    end
    
    # Permissions: An actor may add themselves to any public _joinable_.
    def member_addable_by?(actor)
      return true if public?
      return false
    end
    
    # Permissions: An actor may view this _joinable_ if it is public, if they
    # are the owner, if they are a member or if they have an invite.
    def viewable_by?(actor)
      return true if joinable.public?  \
        || joinable.owner?(actor)      \
        || joinable.has_member?(actor) \
        || joinable.has_invite?(actor) 
        
      return false
    end
    
    # Permission: An actor may remove this _joinable_ if they are the owner
    def destroyable_by?(actor)
      return true if actor == owner
      return false
    end
    
    def self.included(base)
      base.class_eval do
        ## associations
        belongs_to :owner,   :class_name => "User", :foreign_key => 'owner_user_id'
        has_many   :invites, :as => :invitable
        has_and_belongs_to_many :members, :class_name => "User"
        
        ## TODO: these associations may not be used much infavor of Invite.search
        has_many :pending_invites,  :as => :invitable, :class_name => "Invite",
          :conditions => { :status => Invite::Status::PENDING  }
        
        has_many :accepted_invites, :as => :invitable, :class_name => "Invite",
          :conditions => { :status => Invite::Status::ACCEPTED }
        
        has_many :ignored_invites,  :as => :invitable, :class_name => "Invite",
          :conditions => { :status => Invite::Status::IGNORED  }
        
        ## validations
        validates_presence_of :owner
        
        ## callbacks
        after_create   :add_owner_as_member
        before_destroy :remove_all_members
        
        ## enable restful permissions
        has_restful_permissions
        
        ## private instance methods
        private
        
        def add_owner_as_member
          add_member(owner)
        end
      end
    end
  end
end