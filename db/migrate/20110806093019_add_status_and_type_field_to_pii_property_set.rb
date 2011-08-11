class AddStatusAndTypeFieldToPiiPropertySet < ActiveRecord::Migration
  def self.up
    add_column :pii_property_sets, :status, :string
    add_column :pii_property_sets, :threshold_type, :string
  end

  def self.down
    remove_column :pii_property_sets, :threshold_type
    remove_column :pii_property_sets, :status
  end
end
