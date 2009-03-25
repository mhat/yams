#!/usr/bin/env ruby

ActiveRecord::Base.transaction do
  ## generate some users, feel free to change the names
  user1 = User.generate(:email_address => "user1@domain.com", :screen_name => "user1")
  user2 = User.generate(:email_address => "user2@domain.com", :screen_name => "user2")
  user3 = User.generate(:email_address => "user2@domain.com", :screen_name => "user3")

  ## it's tricky to set the password by passing a sym to the generator so ...
  [user1, user2, user3].each do |user|
    user.password="abc123"
    user.save!
  end



  ## create three events for user1
  user1_events   = (1..3).map{ Event.generate!(:owner => user1) }

  ## create three groups for user2
  user2_groups   = (1..3).map{ Group.generate!(:owner => user2) }

  ## create three projects for user3
  user3_projects = (1..3).map{ Project.generate!(:owner => user3) }



  ## user1 is going to send a few invites
  user1_events[1].invite!(user1, user2, "hello there, from 1 to 2")
  user1_events[2].invite!(user1, user2, "hello there, from 1 to 2 (and 3)")
  user1_events[2].invite!(user1, user3, "hello there, from 1 to 2 (and 3)")

  ## user2 is going to invite user1 to three groups
  Invite.send!(user2,user1,"my group 1 is awesome", user2_groups[0])
  Invite.send!(user2,user1,"my group 2 is awesome", user2_groups[1])
  Invite.send!(user2,user1,"my group 3 is awesome", user2_groups[2])
  
  ## user3 is going to invite user1 to a project and user2 to different project
  Invite.send!(user3,user1,"my project", user3_projects[1])
  Invite.send!(user3,user2,"my projcet", user3_projects[2])

  
  ## if everything has gone correctly, user1 should have three sent invites,
  ## user2 should have received two invites and user3 should have one. 

  puts "expect <6,2,1>"
  puts "  user1 has sent #{ user1.sent_invites.size } invites"
  puts "  user2 has recv #{ user2.recv_invites.size } invites"
  puts "  user3 has recv #{ user3.recv_invites.size } invites"

  puts "\n expect <3,0,0> events, <1,3,0> groups"
  puts "  user1 is member of #{ user1.events.size } events, #{ user1.groups.size } groups"
  puts "  user2 is member of #{ user2.events.size } events, #{ user2.groups.size } groups"
  puts "  user3 is member of #{ user3.events.size } events, #{ user3.groups.size } groups"

  ## user2 and user3 accept all their invites
  user2.recv_invites.each{|inv| inv.accept! }
  user3.recv_invites.each{|inv| inv.accept! }

  # user1 ignores two of there three group invites
  user1.recv_invites[0].ignore!
  user1.recv_invites[1].ignore!
  user1.recv_invites[2].accept!
  
  ## because... of course, thx AR
  user1.reload
  user2.reload
  user3.reload

  ## report how many events each user is a member of, should be 3,2,1
  puts "\nexpect <3,2,1>"
  puts "  user1 is member of #{ user1.events.size } events, #{ user1.groups.size } groups"
  puts "  user2 is member of #{ user2.events.size } events, #{ user2.groups.size } groups"
  puts "  user3 is member of #{ user3.events.size } events, #{ user3.groups.size } groups"

  puts "\nI wonder who attending event 1?"
  user1_events[0].members.each{|m| puts "  member: #{m.screen_name}"}

  puts "\nI wonder who attending event 2?"
  user1_events[1].members.each{|m| puts "  member: #{m.screen_name}"}

  puts "\nI wonder who attending event 3?"
  user1_events[2].members.each{|m| puts "  member: #{m.screen_name}"}

  puts "\nI wonder about some general Invite stats:"
  puts "invites total:    #{ Invite.find(:all).count }"
  puts "invites accepted: #{ Invite.search(:statuses => ['accepted']).size }"
  puts "invites pending:  #{ Invite.search(:statuses => ['pending']).size  }"
  puts "invites ignored:  #{ Invite.search(:statuses => ['ignored']).size  }"
end






