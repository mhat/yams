class User < ActiveRecord::Base
  ## associations 
  
  # _Memberable_ models that +User+ owners
  has_many :owner_of_events,   :class_name => 'Event',   :foreign_key => 'owner_user_id'
  has_many :owner_of_groups,   :class_name => 'Group',   :foreign_key => 'owner_user_id'
  has_many :owner_of_projects, :class_name => 'Project', :foreign_key => 'owner_user_id'
  
  # _Memberable_ models that +User+ is a member of
  has_and_belongs_to_many :events
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :projects
  
  # +User's+ +Invite's+ 
  has_many :sent_invites,     :class_name => 'Invite', :foreign_key => 'inviter_user_id'
  has_many :received_invites, :class_name => 'Invite', :foreign_key => 'invitee_user_id'
  
  has_many :accepted_invites, :class_name => 'Invite', :foreign_key => 'invitee_user_id', :conditions => { :status => Invite::Status::ACCEPTED  }
  has_many :pending_invites,  :class_name => 'Invite', :foreign_key => 'invitee_user_id', :conditions => { :status => Invite::Status::PENDING   }
  has_many :ignored_invites,  :class_name => 'Invite', :foreign_key => 'invitee_user_id', :conditions => { :status => Invite::Status::IGNORED   }
  
  def find_all_available_events
    return find_all_available_invitable(Event)
  end
  
  def find_all_available_groups
    return find_all_available_invitable(Group)
  end
  
  def find_all_available_projects
    return find_all_available_invitable(Project)
  end
  
  def find_all_available_inviteable (iv_klass)
    raise ArgumentError, "Invalid tnvitable_type=(#{iv_klass.inspect})" unless (iv_klass.include? Invitable)
    
    all = []
    
    ## first all the events that this user ownes
    all << owner_of_events
    
    ## next all the events that this user is a member of
    all << events
    
    ## next all the events that are publically available
    all << iv_klass.find_by_public(true)
    
    ## should i include pending invitations to events?
    all << pending_invites.select { i.invitable if i.invitable_type == iv_klass.to_s }
    
    return all.flatten.uniq
  end
  
  
  
  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    raise ArgumentError.new "Invalid User, got #{ user inspect }" unless user.is_a?(user)
    Thread.current[:user] = user
  end
end
