class AddDbLevelStuffForEndPointTagRel < ActiveRecord::Migration
  def self.up
    # EndPoints: add foreign keys
    execute <<-SQL
      ALTER TABLE end_point_tag_rels
        ADD CONSTRAINT fk_endPointTagRels_endPoints
        FOREIGN KEY ("endPoint_id")
        REFERENCES end_points(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    execute <<-SQL
      ALTER TABLE end_point_tag_rels
        ADD CONSTRAINT fk_endPointTagRels_tags
        FOREIGN KEY ("tag_id")
        REFERENCES tags(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    # EndPointTagRels: set not null
    execute <<-SQL
      ALTER TABLE end_point_tag_rels
        ALTER COLUMN status SET NOT NULL
    SQL
   # EndPointTagRels: add unique index
    add_index :end_point_tag_rels, [ :endPoint_id, :tag_id], :unique => true, :name => 'by_endPoint_id_tag_id'
  end

  def self.down
    execute <<-SQL
      ALTER TABLE end_point_tag_rels
        DROP CONSTRAINT fk_endPointTagRels_endPoints
    SQL
    execute <<-SQL
      ALTER TABLE end_point_tag_rels
        DROP CONSTRAINT fk_endPointTagRels_tags
    SQL
    execute <<-SQL
      ALTER TABLE end_point_tag_rels
        ALTER COLUMN status DROP NOT NULL
    SQL
    remove_index :end_point_tag_rels, 'by_endPoint_id_tag_id'
  end
end
