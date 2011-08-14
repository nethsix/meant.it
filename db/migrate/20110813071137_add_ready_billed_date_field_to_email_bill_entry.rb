class AddReadyBilledDateFieldToEmailBillEntry < ActiveRecord::Migration
  def self.up
    add_column :email_bill_entries, :ready_date, :datetime
    add_column :email_bill_entries, :billed_date, :datetime
  end

  def self.down
    remove_column :email_bill_entries, :billed_date
    remove_column :email_bill_entries, :ready_date
  end
end
