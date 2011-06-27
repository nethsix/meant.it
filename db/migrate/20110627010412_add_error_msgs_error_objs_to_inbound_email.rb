class AddErrorMsgsErrorObjsToInboundEmail < ActiveRecord::Migration
  def self.up
    add_column :inbound_emails, :error_msgs, :text
    add_column :inbound_emails, :error_objs, :text
  end

  def self.down
    remove_column :inbound_emails, :error_msgs
    remove_column :inbound_emails, :error_objs
  end
end
