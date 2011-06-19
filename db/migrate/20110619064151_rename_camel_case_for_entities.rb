class RenameCamelCaseForEntities < ActiveRecord::Migration
  def self.up
    rename_column :entities, :propertyDocument_id, :property_document_id
  end

  def self.down
    rename_column :entities, :property_document_id, :propertyDocument_id
  end
end
