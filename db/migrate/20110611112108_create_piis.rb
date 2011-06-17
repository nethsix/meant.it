class CreatePiis < ActiveRecord::Migration
  def self.up
    create_table :piis do |t|
      t.string :piiType
      t.string :piiValue
      t.text :piiDesc
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :piis
  end
end
