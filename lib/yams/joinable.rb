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
        after_create :add_owner_as_member
        
        ## private instance methods
        private
        def add_owner_as_member
          add_member(owner)
        end
        
      end
    end
  end
end