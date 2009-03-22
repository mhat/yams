class CreateProjectsUsers < ActiveRecord::Migration
  def self.up
    create_table :projects_users do |t|
      t.integer :project_id, :null => false
      t.integer :user_id,  :null => false
    end
  end

  def self.down
    drop_table :project_users
  end
end
