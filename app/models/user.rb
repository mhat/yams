require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt
  ## permissions
  has_restful_permissions
  
  ## associations 
  
  ## _Joinable_ models that +User+ ownes
  has_many :owner_of_events,   :class_name => 'Event',   :foreign_key => 'owner_user_id'
  has_many :owner_of_groups,   :class_name => 'Group',   :foreign_key => 'owner_user_id'
  has_many :owner_of_projects, :class_name => 'Project', :foreign_key => 'owner_user_id'
  
  ## _Joinable_ models that +User+ is a member of
  has_and_belongs_to_many :events
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :projects
  
  ## +User's+ +Invite's+ 
  has_many :sent_invites, :class_name => 'Invite', :foreign_key => 'inviter_user_id'
  has_many :recv_invites, :class_name => 'Invite', :foreign_key => 'invitee_user_id'
  alias :received_invites :recv_invites
  
  ## TODO: much like their counterparts in Joinable, it's not clear that these
  ## are that useful inlight of Invite.search
  has_many :accepted_invites, :class_name => 'Invite', :foreign_key => 'invitee_user_id', :conditions => { :status => Invite::Status::ACCEPTED  }
  has_many :pending_invites,  :class_name => 'Invite', :foreign_key => 'invitee_user_id', :conditions => { :status => Invite::Status::PENDING   }
  has_many :ignored_invites,  :class_name => 'Invite', :foreign_key => 'invitee_user_id', :conditions => { :status => Invite::Status::IGNORED   }
  
  ##  validations
  validates_presence_of :screen_name
  validates_presence_of :email_address
  validates_presence_of :password_hash
  
  ## callbacks
  
  ## instance methods 
  
  # Returns a list of +Invites+ that +User+ either sent or is the recepiant of!
  #
  def invites
    return Invite.search :from => user, :to => user
  end
  
  # Returns a bcrypt password object suitable for verification
  #
  def password
    @password ||= Password.new(password_hash)
  end
  
  # Encrypt the users password using BCrypt.
  #
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
  # Returns a sanitized hash of this +User. Sanitization will always hide the
  # users password, if User.current_user != self, then the self.email_address
  # will also be sanitized. 
  #
  def to_rest
    safe = Hash.new
    safe.store :user_id,       id
    safe.store :screen_name,   screen_name
    safe.store :created_at,    created_at
    safe.store :updated_at,    updated_at
    safe.store :email_address, email_address if self == User.current_user
    return hash
  end
  
  # Returns a _Joinable_ collection scoped to +User+ for the provided class.
  # The idea here is to be able to get to user.events.find when you could be
  # dealing with some _Joinable_.
  #
  def joinable_by_class (klass=nil)
    return events   if klass == Event
    return groups   if klass == Group
    return projects if klass == Project
    return nil
  end
  
  
  
  ## class methods 
  
  # Authenticate against the provided credentials. If the credentials are
  # valid then an instance of the authenticated user will be available 
  # throughout this +Thread+ via User.current_user
  #
  def self.authenticate(email_address, password)
    # verify the users credential
    requested_user = User.find_by_email_address(email_address)
    return false unless requested_user.password == password
    
    # this makes makes current_user available throughout
    User.current_user = requested_user
    return true
  end
  
  # Sets +User+ as the current user!
  #
  def self.current_user= (user)
    Thread.current[:user] = user
  end
  
  # Provides a easily accessable way to determin who the current user is!
  #
  def self.current_user
    return Thread.current[:user]
  end
  
  # Returns a list of +User's+ with name's likes _name_.
  #
  def self.search_by_partial_screen_name (name)
    criteria = EZ::Where::Condition.new :users do 
      screen_name =~ "#{name}%"
    end
    
    return User.find(:all, :conditions => criteria)
  end
  
end
