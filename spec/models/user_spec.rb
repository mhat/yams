require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  
  
  
  it "should generate a new instance" do
    User.generate!
  end
  
  it "should not create a blank instance" do
    lambda { User.create! }.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  describe "security" do
    it "should encrypt the password" do 
      user = User.generate!
      user.password  = "test"
      user.password != "test"
    end
  
    it "should not authenticate user" do
      user = User.generate!
      User.authenticate(user.email_address, "invalid-password").should == false
    end
    
    it "should authenticate user" do
      user = User.generate!
      user.password = "hello nurse"
      user.save!
      User.authenticate(user.email_address, "hello nurse").should == true
    end
    
    it "should authenticate and set current_user" do
      user = User.generate!
      user.password = "hello nurse"
      user.save!

      User.authenticate(user.email_address, "hello nurse").should == true
      User.current_user.should == user
    end
  end
  
  describe "search" do
    it "should not return any users" do
      User.search_by_partial_screen_name("blah").size.should == 0
    end
    
    it "should return one user" do
      user = User.generate! :screen_name => "monkey"
      User.search_by_partial_screen_name("monk").size.should == 1
    end
    
    it "should return two users" do
      user1 = User.generate! :screen_name => "matt"
      user2 = User.generate! :screen_name => "mark"
      user3 = User.generate! :screen_name => "paul"
      User.search_by_partial_screen_name("ma").size.should == 2
    end
  end
  
  
  
  describe "should have an invitation" do
    before(:each) do
      @from_user = User.generate!
      @to_user   = User.generate!
    end
    
    it "to a event" do
      event  = Event.generate!(:owner => @from_user)
      invite = Invite.send!(@from_user, @to_user, "", event)
      @to_user.received_invites[0].id.should           == invite.id
      @to_user.received_invites[0].invitable_id.should == event.id
    end
    
    it "to a group" do
      group  = Group.generate!(:owner => @from_user)
      invite = Invite.send!(@from_user, @to_user, "", group)
      @to_user.received_invites[0].id.should           == invite.id
      @to_user.received_invites[0].invitable_id.should == group.id
    end
    
    it "to a project" do
      project = Project.generate!(:owner => @from_user)
      invite  = Invite.send!(@from_user, @to_user, "", project)
      @to_user.received_invites[0].id.should           == invite.id
      @to_user.received_invites[0].invitable_id.should == project.id
    end
  end
  
  
  
  describe "should have" do
    before(:each) do
      @from_user = User.generate!
      @to_user   = User.generate!
    end
    
    it "a pending invitation" do
      invite = Invite.send!(@from_user, @to_user, "", Event.generate!(:owner => @from_user))
      @to_user.pending_invites[0].id.should == invite.id
    end
    
    it "an accepted invitation" do
      invite = Invite.send!(@from_user, @to_user, "", Event.generate!(:owner => @from_user))
      invite.accept!
      @to_user.accepted_invites[0].id.should == invite.id
    end
    
    it "an ignored invitation" do
      invite = Invite.send!(@from_user, @to_user, "", Event.generate!(:owner => @from_user))
      invite.ignore!
      @to_user.ignored_invites[0].id.should == invite.id
    end
  end
end
