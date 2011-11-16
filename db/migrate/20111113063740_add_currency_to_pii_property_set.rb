class AddCurrencyToPiiPropertySet < ActiveRecord::Migration
  def self.up
    add_column :pii_property_sets, :currency, :string
  end

  def self.down
    remove_column :pii_property_sets, :currency
  end
end
