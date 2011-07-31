class CreatePiiPropertySets < ActiveRecord::Migration
  def self.up
    create_table :pii_property_sets do |t|
      t.string :uniq_id
      t.string :short_desc
      t.text :long_desc
      t.string :notify
      t.integer :threshold
      t.integer :pii_id
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :pii_property_sets
  end
end
