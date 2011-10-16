class AddNickFieldInEntityDatum < ActiveRecord::Migration
  def self.up
    add_column :entity_data, :nick, :string
  end

  def self.down
    remove_column :entity_data, :nick
  end
end
