class ModifyPropertyDocumentIdInEntity < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      ALTER TABLE entities
        ALTER COLUMN property_document_id DROP NOT NULL
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE entities
        ALTER COLUMN "property_document_id" SET NOT NULL
    SQL
  end
end
