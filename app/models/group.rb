class Group < ActiveRecord::Base
  ## enable restful permissions, must do this before including Joinable :|
  has_restful_permissions
  
  include YAMS::Joinable
end
