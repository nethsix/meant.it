class AddNormMessageToMeantItRel < ActiveRecord::Migration
  def self.up
    add_column :meant_it_rels, :norm_message, :text
  end

  def self.down
    remove_column :meant_it_rels, :norm_message
  end
end
