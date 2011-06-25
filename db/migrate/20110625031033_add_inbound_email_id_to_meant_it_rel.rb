class AddInboundEmailIdToMeantItRel < ActiveRecord::Migration
  def self.up
    add_column :meant_it_rels, :inbound_email_id, :integer

    # Add foreign keys
    execute <<-SQL
      ALTER TABLE meant_it_rels
        ADD CONSTRAINT fk_meantItRels_inboundEmails
        FOREIGN KEY ("inbound_email_id")
        REFERENCES inbound_emails(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL

    # Add index
    add_index :meant_it_rels, [ :inbound_email_id ], :unique => true, :name => 'by_inbound_email_id'
  end

  def self.down
    remove_column :meant_it_rels, :inbound_email_id
  end
end
