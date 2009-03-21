class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer  :user_id
      t.boolean  :public
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
