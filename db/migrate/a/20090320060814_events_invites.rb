class EventsInvites < ActiveRecord::Migration
  def self.up
    create_table :events_invites do |t|
      t.integer :event_id
      t.integer :invite_id
    end
  end
  
  def self.down
    drop_table :events_invites
  end
end
