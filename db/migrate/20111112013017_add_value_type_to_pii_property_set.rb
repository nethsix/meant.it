require 'validators'
class AddValueTypeToPiiPropertySet < ActiveRecord::Migration
  def self.up
    add_column :pii_property_sets, :value_type, :string
    PiiPropertySet.update_all ["value_type = ?", ValueTypeValidator::VALUE_TYPE_COUNT_UNIQ]
    execute <<-SQL
      ALTER TABLE pii_property_sets
        ALTER COLUMN value_type SET NOT NULL
    SQL
  end

  def self.down
    remove_column :pii_property_sets, :value_type
  end
end
