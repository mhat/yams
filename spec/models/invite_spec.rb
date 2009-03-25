require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Invite do
  before(:each) do
  end
  
  it "should create a new instance given valid attributes" do
    Invite.create! do |invite|
      invite.invitee_user_id = User.generate!.id
      invite.inviter_user_id = User.generate!.id
      invite.note = ''
    end
  end
  
  describe "status" do
    before(:each) do 
      @invite = Invite.generate!
    end
    
    it "should default to pending" do
      @invite.status.should == Invite::Status::PENDING
    end
    
    it "should be set to ignored" do 
      @invite.ignore!
      @invite.status.should == Invite::Status::IGNORED
    end
    
    it "should be set to accepted" do
      @invite.accept!
      @invite.status.should == Invite::Status::ACCEPTED
    end
  end
  
  describe "inquery" do
    before(:each) do
      @invite = Invite.generate!
    end
    
    it "should not confirm that the user is the invitee" do
      @invite.invitee?(User.generate!).should == false
    end
    
    it "should confirm that the user is the invitee" do
      @invite.invitee?(@invite.invitee).should == true
    end
    
    it "should not confirm that the user is the inviter" do
      @invite.inviter?(User.generate!).should == false
    end
    
    it "should confirm that the user is the inviter" do
      @invite.inviter?(@invite.inviter).should == true
    end
  end
  
  describe "permissions" do
    before(:each) do
      @invite = Invite.generate
    end
    
    it "should not allow update" do
      @invite.updatable_by?(@invite.inviter).should == false
    end
     
    it "should allow update" do
      @invite.updatable_by?(@invite.invitee).should == true
    end
    
    it "should not allow destroy" do
      @invite.destroyable_by?(@invite.invitee).should == false
    end
        
    it "should allow destroy" do
      @invite.destroyable_by?(@invite.inviter).should == true
    end
  end
  
  describe "search" do 
    before(:all) do
      @pending  = Invite::Status::PENDING
      @ignored  = Invite::Status::IGNORED
      @accepted = Invite::Status::ACCEPTED
      
      @from     = User.generate!
      @to       = User.generate!
      @invites  = [
        {:inviter => @from, :invitee => @to,   :status => @pending,  :invitable => Event.generate!},
        {:inviter => @from, :invitee => @to,   :status => @ignored,  :invitable => Group.generate!},
        {:inviter => @from, :invitee => @to,   :status => @accepted, :invitable => Project.generate!},
        {:inviter => @to,   :invitee => @from, :status => @accepted, :invitable => Project.generate!}
      ]
      
      @invites.each { |i| Invite.generate(i) }
    end
      
    it "should return one event, ignoring spam" do
      Invite.search(:from => @from, :types => ['event', 'monkey']).size.should  == 1
    end
    
    it "should return a pending, ignoring spam" do
      Invite.search(:from => @from, :statuses => ['pending', 'monkey']).size.should == 1
    end
    
    it "should return one group" do
      Invite.search(:from => @from, :types => ['group']).size.should == 1
    end
    
    it "should return one project" do
      Invite.search(:from => @from, :types => ['project']).size.should == 1
    end
    
    it "should return a event and a group" do
      Invite.search(:from => @from, :types => ['event', 'group']).size.should == 2
    end
    
    it "should return one from" do
      Invite.search(:from => @to).size.should == 1
    end
    
    it "should return three from" do 
      Invite.search(:from => @from).size.should == 3
    end
      
    it "should return one to" do
      Invite.search(:to => @from).size.should == 1
    end
    
    it "should return three to" do 
      Invite.search(:to => @to).size.should == 3
    end
    
    it "should return four by send and received" do
      Invite.search(:to => @from, :from => @from).size.should == 4
    end
    
    it "should return one ignored" do 
      Invite.search(:from => @from, :statuses => ['ignored']).size.should == 1
    end
    
    it "should return one accepted" do
      Invite.search(:from => @from, :statuses => ['accepted']).size.should == 1
    end
    
    it "should return a pending and a ignored" do
      Invite.search(:from => @from, :statuses => ['pending', 'ignored']).size.should == 2
    end
    
    it "should return one by from, to, project and accepted" do
      Invite.search(
        :from     => @from,
        :to       => @to,
        :statuses => ['accepted'],
        :types    => ['project']
      ).size.should == 1
    end
  end
end
