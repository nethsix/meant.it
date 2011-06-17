class AddDbLevelStuffForEndPoint < ActiveRecord::Migration
  def self.up
    # EndPoints: add foreign keys
    execute <<-SQL
      ALTER TABLE end_points
        ADD CONSTRAINT fk_endPoints_creatorEndPoints
        FOREIGN KEY ("creatorEndPoint_id")
        REFERENCES end_points(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    # EndPoints: set not null 
    execute <<-SQL
      ALTER TABLE end_points
        ALTER COLUMN "startTime" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE end_points
        ALTER COLUMN "status" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE end_points
        ALTER COLUMN "nick" SET NOT NULL
    SQL
    # EndPoints: set unique
    add_index :end_points, [ :nick, :creatorEndPoint_id ], :unique => true, :name => 'by_nick_and_creatorEndPoint_id'
    

  end

  def self.down
  end
end
