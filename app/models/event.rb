class Event < ActiveRecord::Base
  include YAMS::Memberable
  include YAMS::Inviteable
end