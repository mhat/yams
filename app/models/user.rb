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
  
  
  ## validators
  validates_presence_of :screen_name
  validates_presence_of :email_address
  validates_presence_of :password_hash
  
  
  ## callbacks
  
  
  ## instance methods 
  
  def password
    @password ||= Password.new(password_hash)
  end
  
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
  ## class methods 
  def self.authenticate(email_address, password_hash)
    return false unless User.find_by_email_address(email_address).password.to_s == password_hash
    return true
  end
  
end
