class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :screen_name,   :null => false, :unique => true
      t.string :email_address, :null => false, :unique => true
      t.string :password_hash, :null => false
      t.timestamps
    end
    
    add_index :users, [:screen_name  ]
    add_index :users, [:email_address]
  end

  def self.down
    drop_table :users
  end
end
