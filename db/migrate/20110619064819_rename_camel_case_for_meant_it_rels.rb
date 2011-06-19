class RenameCamelCaseForMeantItRels < ActiveRecord::Migration
  def self.up
    rename_column :meant_it_rels, :srcEndPoint_id, :src_endpoint_id
    rename_column :meant_it_rels, :dstEndPoint_id, :dst_endpoint_id
    rename_column :meant_it_rels, :messageType, :message_type
  end

  def self.down
    rename_column :meant_it_rels, :src_endpoint_id, :srcEndPoint_id
    rename_column :meant_it_rels, :dst_endpoint_id, :dstEndPoint_id
    rename_column :meant_it_rels, :message_type, :messageType
  end
end
