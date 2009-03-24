class CreateProjectsUsers < ActiveRecord::Migration
  def self.up
    create_table :projects_users, :id => false do |t|
      t.integer :project_id, :null => false
      t.integer :user_id,  :null => false
    end
    
    add_index :projects_users, [:project_id, :user_id]
  end

  def self.down
    drop_table :project_users
  end
end
