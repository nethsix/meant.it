class RenameCamelCaseForPiis < ActiveRecord::Migration
  def self.up
   rename_column :piis, :piiType, :pii_type
   rename_column :piis, :piiValue, :pii_value
   rename_column :piis, :piiDesc, :pii_desc
   rename_column :piis, :endPoint_id, :endpoint_id
  end

  def self.down
   rename_column :piis, :pii_type, :piiType
   rename_column :piis, :pii_value, :piiValue
   rename_column :piis, :pii_desc, :piiDesc
   rename_column :piis, :endpoint_id, :endPoint_id 
  end
end
