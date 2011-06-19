class RenameCamelCaseForObjRels < ActiveRecord::Migration
  def self.up
   rename_column :obj_rels, :srcObj_id, :srcobj_id
   rename_column :obj_rels, :dstObj_id, :dstobj_id
   rename_column :obj_rels, :relType, :rel_type
   rename_column :obj_rels, :relDesc, :rel_desc
   rename_column :obj_rels, :relObjType, :rel_obj_type
  end

  def self.down
   rename_column :obj_rels, :srcobj_id, :srcObj_id
   rename_column :obj_rels, :dstobj_id, :dstObj_id
   rename_column :obj_rels, :rel_type, :relType
   rename_column :obj_rels, :rel_desc, :relDesc
   rename_column :obj_rels, :rel_obj_type, :relObjType
  end
end
