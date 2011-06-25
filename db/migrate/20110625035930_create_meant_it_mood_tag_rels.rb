class CreateMeantItMoodTagRels < ActiveRecord::Migration
  def self.up
    create_table :meant_it_mood_tag_rels do |t|
      t.integer :meant_it_rel_id
      t.integer :tag_id
      t.string :reasoner
      t.string :status

      t.timestamps
    end
    # Add foreign keys
    execute <<-SQL
      ALTER TABLE meant_it_mood_tag_rels
        ADD CONSTRAINT fk_meantItMoodTagRels_meantItRels
        FOREIGN KEY ("meant_it_rel_id")
        REFERENCES meant_it_rels(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    execute <<-SQL
      ALTER TABLE meant_it_mood_tag_rels
        ADD CONSTRAINT fk_meantItMoodTagRels_tags
        FOREIGN KEY ("tag_id")
        REFERENCES tags(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL

    # Add not null
    execute <<-SQL
      ALTER TABLE meant_it_mood_tag_rels ALTER reasoner SET NOT NULL
    SQL

    execute <<-SQL
      ALTER TABLE meant_it_mood_tag_rels ALTER status SET NOT NULL
    SQL


    # Add index
    add_index :meant_it_mood_tag_rels, [ :meant_it_rel_id, :tag_id, :reasoner ], :unique => true, :name => 'by_meant_it_rel_id_and_tag_id_and_reasoner'
  end

  def self.down
    drop_table :meant_it_mood_tag_rels
  end
end
