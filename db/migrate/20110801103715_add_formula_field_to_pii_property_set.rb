class AddFormulaFieldToPiiPropertySet < ActiveRecord::Migration
  def self.up
    add_column :pii_property_sets, :formula, :string
  end

  def self.down
    remove_column :pii_property_sets, :formula
  end
end
