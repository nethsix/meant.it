class AddEmailBillEntryIdFieldToMeantItRel < ActiveRecord::Migration
  def self.up
    add_column :meant_it_rels, :email_bill_entry_id, :integer
  end

  def self.down
    remove_column :meant_it_rels, :email_bill_entry_id
  end
end
