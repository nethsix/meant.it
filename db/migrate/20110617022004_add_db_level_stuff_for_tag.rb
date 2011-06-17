class AddDbLevelStuffForTag < ActiveRecord::Migration
  def self.up
    # Tags: add foreign keys
    # None
    # Tags: set not null
    execute <<-SQL
      ALTER TABLE tags
        ALTER COLUMN name SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE tags
        ALTER COLUMN status SET NOT NULL
    SQL
    # Tags: add_index
    add_index :tags, [ :name ], :unique => true, :name => 'by_name'
  end

  def self.down
  end
end
