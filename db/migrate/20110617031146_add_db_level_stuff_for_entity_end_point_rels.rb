class AddDbLevelStuffForEntityEndPointRels < ActiveRecord::Migration
  def self.up
    # EntityEndPoints: add foreign keys
    execute <<-SQL
      ALTER TABLE entity_end_point_rels
        ADD CONSTRAINT fk_entityEndPointRels_endPoints
        FOREIGN KEY ("endPoint_id")
        REFERENCES end_points(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    execute <<-SQL
      ALTER TABLE entity_end_point_rels
        ADD CONSTRAINT fk_endtityEndPointRels_entities
        FOREIGN KEY ("entity_id")
        REFERENCES entities(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    # EntityEndPoints: set not null
    execute <<-SQL
      ALTER TABLE entity_end_point_rels
        ALTER COLUMN "verificationType" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE entity_end_point_rels
        ALTER COLUMN status SET NOT NULL
    SQL
    # EntityEndPoints: add unique index
    add_index :entity_end_point_rels, [ :endPoint_id, :entity_id, :verificationType], :unique => true, :name => 'by_endPoint_id_and_entity_id_and_verificationType'
  end

  def self.down
    execute <<-SQL
      ALTER TABLE entity_end_point_rels
        DROP CONSTRAINT fk_entityEndPointRels_endPoints
    SQL
    execute <<-SQL
      ALTER TABLE entity_end_point_rels
        DROP CONSTRAINT fk_endtityEndPointRels_entities
    SQL
    execute <<-SQL
      ALTER TABLE entity_end_point_rels
        DROP COLUMN "verificationType" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE entity_end_point_rels
        DROP COLUMN status SET NOT NULL
    SQL
    remove_index :entity_end_point_rels, 'by_endPoint_id_and_entity_id_and_verificationType'
  end
end
