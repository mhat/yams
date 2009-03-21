class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      
      t.integer  :owner_user_id, :null => false
      t.boolean  :public,        :null => false, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
