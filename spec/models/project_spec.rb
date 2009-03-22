require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  before(:each) do
  end
  
  it "should create a new instance given valid attributes" do
    Project.create!(:owner => User.generate!)
  end
end
