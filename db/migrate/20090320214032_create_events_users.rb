class CreateEventsUsers < ActiveRecord::Migration
  def self.up
    create_table :events_users do |t|
      t.integer :event_id, :null => false
      t.integer :user_id,  :null => false
    end
  end

  def self.down
    drop_table :events_users
  end
end
