class CreateEndPoints < ActiveRecord::Migration
  def self.up
    create_table :end_points do |t|
      t.integer :creatorEndPoint_id
      t.timestamp :startTime
      t.timestamp :endTime
      t.string :nick
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :end_points
  end
end
