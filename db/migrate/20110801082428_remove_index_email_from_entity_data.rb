class RemoveIndexEmailFromEntityData < ActiveRecord::Migration
  def self.up
    remove_index :entity_data, :name => 'by_email'
  end

  def self.down
    add_index :entity_data, [ :email ], :unique => true, :name => 'by_email'
  end
end
