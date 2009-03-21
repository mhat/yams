class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.integer    :inviter_user_id,  :null => false
      t.integer    :invitee_user_id,  :null => false
      t.string     :note
      t.integer    :status,           :null => false, :default => Invite::Status::PENDING
      t.references :invitable,        :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :invites
  end
end
