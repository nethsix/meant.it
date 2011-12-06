class AddAndRemoveFieldsToPayment < ActiveRecord::Migration
  def self.up
    # Add new fields
   change_table :payments do |t|
      t.string :item_name
      t.string :item_no
      t.float :unit_weight
      t.float :quantity
      t.float :discount_amount1
      t.float :discount_amount2
      t.float :discount_rate1
      t.float :discount_rate2
      t.float :tax_rate1
      t.float :tax_rate2
      t.float :shipping1
      t.float :shipping2
      t.remove :shipping
    end # end change_table :payments
  end

  def self.down
   change_table :payments do |t|
      t.remove :item_name
      t.remove :item_no
      t.remove :unit_weight
      t.remove :quantity
      t.remove :discount_amount1
      t.remove :discount_amount2
      t.remove :discount_rate1
      t.remove :discount_rate2
      t.remove :tax_rate1
      t.remove :tax_rate2
      t.remove :shipping1
      t.remove :shipping2
      t.float :shipping
    end # end change_table :payments
  end
end
