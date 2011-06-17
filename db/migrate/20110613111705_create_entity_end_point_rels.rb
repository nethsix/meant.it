class CreateEntityEndPointRels < ActiveRecord::Migration
  def self.up
    create_table :entity_end_point_rels do |t|
      t.integer :entity_id
      t.integer :endPoint_id
      t.string :verificationType
      t.text :verificationDesc
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :entity_end_point_rels
  end
end
