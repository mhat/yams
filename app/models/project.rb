class Project < ActiveRecord::Base
  include YAMS::Memberable
  include YAMS::Inviteable
end
