class AddFieldsToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :currency_code, :string
    add_column :payments, :country, :string
    add_column :payments, :payee, :string
  end

  def self.down
    remove_column :payments, :payee
    remove_column :payments, :country
    remove_column :payments, :currency_code
  end
end
