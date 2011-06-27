class AddNormNameNormDescToTag < ActiveRecord::Migration
  def self.up
    add_column :tags, :norm_name, :string
    add_column :tags, :norm_desc, :text
  end

  def self.down
    remove_column :tags, :norm_desc
    remove_column :tags, :norm_name
  end
end
