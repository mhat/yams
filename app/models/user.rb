require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt
  
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
  
  
  ## validating
  validates_presence_of :screen_name
  validates_presence_of :email_address
  validates_presence_of :password_hash
  
  
  ## callbacks
  
  
  ## instance methods 
  
  def invites
    return Invite.search :from => user, :to => user
  end
  
  
  def password
    @password ||= Password.new(password_hash)
  end
  
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
  # returns a sanitized hash suitable for sending to a rest client
  def to_rest
    return {
      'user_id'       => id,
      'screen_name'   => screen_name,
      'email_address' => email_address, 
      'created_at'    => created_at,
      'updated_at'    => updated_at
    }
  end
  
  # get a joinable collection by passing in a joinable class
  def joinable_by_class (klass=nil)
    return events   if klass == Event
    return groups   if klass == Group
    return projects if klass == Project
    return nil
  end
  
  ## class methods 
  
  # Authenticate the povided credentials, if authentic then make the user
  # available throughout this +Thread+.
  #
  def self.authenticate(email_address, password)
    # verify the users credential
    requested_user = User.find_by_email_address(email_address)
    return false unless requested_user.password == password
    
    # this makes makes current_user available throughout
    User.current_user = requested_user
    return true
  end
  
  # mutator to set the +current_user+
  def self.current_user= (user)
    Thread.current[:user] = user
  end
  
  # accessor to get the +current_user+
  def self.current_user
    return Thread.current[:user]
  end

  # search for screen names like 
  def self.search_by_partial_screen_name (name)
    criteria = EZ::Where::Condition.new :users do 
      screen_name =~ "#{name}%"
    end
    return User.find(:all, :conditions => criteria)
  end
  
end
