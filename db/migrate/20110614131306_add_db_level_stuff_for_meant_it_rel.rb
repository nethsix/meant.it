class AddDbLevelStuffForMeantItRel < ActiveRecord::Migration
  def self.up
    # MeantItRels: add a foreign key
    execute <<-SQL
      ALTER TABLE meant_it_rels 
        ADD CONSTRAINT fk_meantItRels_srcEndPoints
        FOREIGN KEY ("srcEndPoint_id")
        REFERENCES end_points(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    execute <<-SQL
      ALTER TABLE meant_it_rels
        ADD CONSTRAINT fk_meantItRels_dstEndPoints
        FOREIGN KEY ("dstEndPoint_id")
        REFERENCES end_points(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    # MeantItRels: set not null
    execute <<-SQL
      ALTER TABLE meant_it_rels
        ALTER COLUMN "srcEndPoint_id" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE meant_it_rels
        ALTER COLUMN "dstEndPoint_id" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE meant_it_rels
        ALTER COLUMN "messageType" SET NOT NULL
    SQL
    # MeantItRels: add unique
    # NONE
  end

  def self.down
  end
end
