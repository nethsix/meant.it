class CreateEmailBillEntries < ActiveRecord::Migration
  def self.up
    create_table :email_bill_entries do |t|
      t.integer :email_bill_id
      t.integer :pii_property_set_id

      t.timestamps
    end
  end

  def self.down
    drop_table :email_bill_entries
  end
end
