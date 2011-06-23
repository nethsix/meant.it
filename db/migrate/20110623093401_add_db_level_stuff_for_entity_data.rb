class AddDbLevelStuffForEntityData < ActiveRecord::Migration
  def self.up
    add_index :entity_data, [ :email ], :unique => true, :name => 'by_email'
  end

  def self.down
  end
end
