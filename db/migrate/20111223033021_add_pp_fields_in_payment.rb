class AddPpFieldsInPayment < ActiveRecord::Migration
  def self.up
    change_table :payments do |t|
      t.text :pp_ipn_parms
      t.string :pp_trans_id
      t.string :pp_status
    end # end change_table :payments ...
  end

  def self.down
    change_table :payments do |t|
      t.remove :pp_ipn_parms
      t.remove :pp_trans_id
      t.remove :pp_status
    end # end change_table :payments ...
  end
end
