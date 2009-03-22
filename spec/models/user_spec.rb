require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @from_user = User.generate!
    @to_user   = User.generate!
  end
  
  it "should create a new instance" do
    User.create!
  end
  
  describe "should have an invitation" do
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
