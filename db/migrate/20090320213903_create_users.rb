class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string      :screen_name,   :null => false, :unique => true
      t.string      :email_address, :null => false, :unique => true
      t.string      :password_hash, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
