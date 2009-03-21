require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Invite do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Invite.create! do |invite|
      invite.invitee_user_id = User.generate!.id
      invite.inviter_user_id = User.generate!.id
    end
  end
end
