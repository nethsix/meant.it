class CreateObjRels < ActiveRecord::Migration
  def self.up
    create_table :obj_rels do |t|
      t.integer :srcObj_id
      t.integer :dstObj_id
      t.string :relType
      t.string :relDesc
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :obj_rels
  end
end
