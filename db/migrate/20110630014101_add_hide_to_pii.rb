class AddHideToPii < ActiveRecord::Migration
  def self.up
    add_column :piis, :pii_hide, :string
  end

  def self.down
    remove_column :piis, :pii_hide
  end
end
