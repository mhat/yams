class User < ActiveRecord::Base
  generator_for :email_address, :start => "user1@example.com" do |prev|
    name, domain = prev.split('@')
    name.succ!
    [name,domain].join('@')
  end
  
  generator_for :password_hash do |prev|
    BCrypt::Password.create Array.new(16).map { (65 + rand(58)).chr }.join
  end
end