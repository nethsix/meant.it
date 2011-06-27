class AddDbLevelStuffForEntity < ActiveRecord::Migration
  def self.up
    # Entities: add foreign key
    # Foreign key is in couchdb, and we use validation to enforce
    # Entitites: set not null
    execute <<-SQL
      ALTER TABLE entities
        ALTER COLUMN "propertyDocument_id" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE entities
        ALTER COLUMN status SET NOT NULL
    SQL
    # Entitites: add unique index
    add_index :entities, [ :id, :propertyDocument_id ], :unique => true, :name => 'by_id_and_propertyDocument_id'
  end

  def self.down
    execute <<-SQL
      ALTER TABLE entities
        ALTER COLUMN propertyDocument_id DROP NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE entities
        ALTER COLUMN status DROP NOT NULL
    SQL
    remove_index :entities, 'by_id_and_propertyDocument_id'
  end
end
