class AddRelObjTypeToObjRels < ActiveRecord::Migration
  def self.up
    add_column :obj_rels, :relObjType, :string
  end

  def self.down
    remove_column :obj_rels, :relObjType
  end
end
