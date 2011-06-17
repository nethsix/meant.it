class AddEndPointIdToPii < ActiveRecord::Migration
  def self.up
    add_column :piis, :endPoint_id, :integer
  end

  def self.down
    remove_column :piis, :endPoint_id
  end
end
