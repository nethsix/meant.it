class AddDbLevelStuffForObjRel < ActiveRecord::Migration
  def self.up
    # ObjRels: add a foreign key
    # NONE: ObjRels handle polymorphic foreign keys!!
    # ObjRels: set not null
    execute <<-SQL
      ALTER TABLE obj_rels
        ALTER COLUMN "srcObj_id" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE obj_rels
        ALTER COLUMN "dstObj_id" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE obj_rels
        ALTER COLUMN "relType" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE obj_rels
        ALTER COLUMN "status" SET NOT NULL
    SQL
    # ObjRels: set unique
    add_index :obj_rels, [ :srcObj_id, :dstObj_id, :relType ], :unique => true, :name => 'by_srcObj_id_and_dstObj_id_and_relType'
  end

  def self.down
  end
end
