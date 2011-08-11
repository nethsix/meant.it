class CreateEmailBills < ActiveRecord::Migration
  def self.up
    create_table :email_bills do |t|
      t.integer :entity_id

      t.timestamps
    end
  end

  def self.down
    drop_table :email_bills
  end
end
