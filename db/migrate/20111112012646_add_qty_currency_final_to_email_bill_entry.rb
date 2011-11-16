class AddQtyCurrencyFinalToEmailBillEntry < ActiveRecord::Migration
  def self.up
    add_column :email_bill_entries, :qty, :float
    add_column :email_bill_entries, :currency, :string
    add_column :email_bill_entries, :price_final, :float
    add_column :email_bill_entries, :threshold_final, :float
  end

  def self.down
    remove_column :email_bill_entries, :threshold_final
    remove_column :email_bill_entries, :price_final
    remove_column :email_bill_entries, :currency
    remove_column :email_bill_entries, :qty
  end
end
