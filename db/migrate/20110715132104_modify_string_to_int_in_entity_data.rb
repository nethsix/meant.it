class ModifyStringToIntInEntityData < ActiveRecord::Migration
  def self.up
    remove_column :entity_data, :credit_card_exp_yyyy
    add_column :entity_data, :credit_card_exp_yyyy, :integer
    remove_column :entity_data, :credit_card_exp_mm
    add_column :entity_data, :credit_card_exp_mm, :integer
  end

  def self.down
    remove_column :entity_data, :credit_card_exp_yyyy
    add_column :entity_data, :credit_card_exp_yyyy, :string
    remove_column :entity_data, :credit_card_exp_mm
    add_column :entity_data, :credit_card_exp_mm, :string
  end
end
