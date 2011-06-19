class RenameCamelCaseForEndPointTagRels < ActiveRecord::Migration
  def self.up
    rename_column :end_point_tag_rels, :endPoint_id, :endpoint_id
  end

  def self.down
    rename_column :end_point_tag_rels, :endpoint_id, :endPoint_id
  end
end
