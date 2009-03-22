module YAMS::Memberable
  # Convince method to add the provided +User+. Does nothing if the +User+ is
  # already a memeber.
  #
  def add_member(user)
    members << user unless has_member? user
  end
  
  # Convince method to remove the provided +User+. Does nothing if the +User+
  # is not a member.
  #
  def remove_member(user)
    members.remove user if has_member? user
  end
  
  # Convince method to determine if a +User+ is a member.
  #
  def has_member?(user)
    members.exists?(user)
  end
  
  # Defines associations for _Memberable_ models.
  # * members:: returns the member +User's+
  # 
  # Defines callbacks for _Memberable_ models.
  # * after_create:: ensures that the owning +User+ is also a member.
  #
  def self.included(base)
    base.class_eval do
      has_and_belongs_to_many :members, :class_name => "User"
      
      after_create            :add_owner_as_member
      private
        def add_owner_as_member
          members << owner
        end
    end
  end
end
  