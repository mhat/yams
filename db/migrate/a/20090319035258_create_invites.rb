class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.integer     :user_id
      t.string      :note
      t.boolean     :accepted
      t.timestamps
    end
  end

  def self.down
    drop_table :invites
  end
end
