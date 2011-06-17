class ModifyDocIdInEntity < ActiveRecord::Migration
  def self.up
    change_table :entities do |t|
      t.rename :doc_id, :propertyDocument_id
    end
  end

  def self.down
    change_table :entities do |t|
      t.rename :propertyDocument_id, :doc_id
    end
  end
end
