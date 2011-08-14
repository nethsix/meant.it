class AddActiveDateFieldToPiiPropertySet < ActiveRecord::Migration
  def self.up
    add_column :pii_property_sets, :active_date, :datetime
  end

  def self.down
    remove_column :pii_property_sets, :active_date
  end
end
