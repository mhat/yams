class Invite < ActiveRecord::Base
  generator_for :note, :start => "Test Note" do |prev|
    prev.succ
  end
  
  generator_for :invitee do
     User.generate!
   end
   
  generator_for :inviter do
    User.generate!
  end
  
  generator_for :invitable do
    Event.generate!
  end
    
end