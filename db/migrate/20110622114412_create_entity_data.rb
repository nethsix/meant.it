class CreateEntityData < ActiveRecord::Migration
  def self.up
    create_table :entity_data do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :dob_yyyy
      t.integer :dob_mm
      t.integer :dob_dd
      t.string :address_1
      t.string :address_2
      t.text :address_3
      t.string :city
      t.string :state
      t.string :country
      t.integer :credit_card_no_1
      t.integer :credit_card_no_2
      t.integer :credit_card_no_3
      t.integer :credit_card_no_4
      t.string :credit_card_exp_yyyy
      t.string :credit_card_exp_mm
      t.integer :credit_card_ccv

      t.timestamps
    end
  end

  def self.down
    drop_table :entity_data
  end
end
