class CreateInboundEmailLogs < ActiveRecord::Migration
  def self.up
    create_table :inbound_email_logs do |t|
      t.text :params_txt
      t.text :error_msgs
      t.text :error_objs

      t.timestamps
    end
  end

  def self.down
    drop_table :inbound_email_logs
  end
end
