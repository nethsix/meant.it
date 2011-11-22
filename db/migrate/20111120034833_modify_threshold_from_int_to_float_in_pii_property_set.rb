class ModifyThresholdFromIntToFloatInPiiPropertySet < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      ALTER TABLE pii_property_sets
        ALTER COLUMN threshold TYPE float
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE pii_property_sets
        ALTER COLUMN threshold TYPE integer
    SQL
  end
end
