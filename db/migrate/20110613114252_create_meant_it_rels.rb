class CreateMeantItRels < ActiveRecord::Migration
  def self.up
    create_table :meant_it_rels do |t|
      t.integer :srcEndPoint_id
      t.integer :dstEndPoint_id
      t.string :messageType
      t.text :message
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :meant_it_rels
  end
end
