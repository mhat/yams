class Invite < ActiveRecord::Base
  generator_for :note, :start => "Test Note" do |prev|
    prev.succ
  end
end