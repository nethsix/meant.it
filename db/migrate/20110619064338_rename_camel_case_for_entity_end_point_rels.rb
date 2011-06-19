class RenameCamelCaseForEntityEndPointRels < ActiveRecord::Migration
  def self.up
   rename_column :entity_end_point_rels, :endPoint_id, :endpoint_id
   rename_column :entity_end_point_rels, :verificationType, :verification_type
   rename_column :entity_end_point_rels, :verificationDesc, :verification_desc
  end

  def self.down
   rename_column :entity_end_point_rels, :endpoint_id, :endPoint_id
   rename_column :entity_end_point_rels, :verification_type, :verificationType
   rename_column :entity_end_point_rels, :verification_desc, :verificationDesc
  end
end
