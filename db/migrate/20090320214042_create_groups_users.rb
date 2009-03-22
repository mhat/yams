class CreateGroupsUsers < ActiveRecord::Migration
  def self.up
    create_table :groups_users do |t|
      t.integer :group_id, :null => false
      t.integer :user_id,  :null => false
    end
  end

  def self.down
    drop_table :groups_users
  end
end
