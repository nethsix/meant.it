class CreateEndPointTagRels < ActiveRecord::Migration
  def self.up
    create_table :end_point_tag_rels do |t|
      t.integer :endPoint_id
      t.integer :tag_id
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :end_point_tag_rels
  end
end
