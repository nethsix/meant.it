class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :mir_id
      t.string :invoice_no
      t.string :status
      t.text :message
      t.string :return_code
      t.float :amount
      t.float :shipping
      t.float :tax1
      t.float :tax2
      t.float :total

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
