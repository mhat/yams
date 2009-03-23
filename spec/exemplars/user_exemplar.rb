class User < ActiveRecord::Base
  
  generator_for :screen_name   do
    token = sprintf("%x", Time.now.to_f*(10**5))
    "user_#{token}"
  end
  
  generator_for :email_address do 
    token = sprintf("%x", Time.now.to_f*(10**5))
    "user_#{ token }@domain.com"
  end
  
  generator_for :password_hash do |prev|
    BCrypt::Password.create Array.new(16).map { (65 + rand(58)).chr }.join
  end
end