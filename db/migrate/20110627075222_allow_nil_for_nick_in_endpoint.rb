class AllowNilForNickInEndpoint < ActiveRecord::Migration
  def self.up
    execute <<-SQL 
      ALTER TABLE end_points
        ALTER COLUMN "nick" DROP NOT NULL
    SQL
  end

  def self.down
    execute <<-SQL 
      ALTER TABLE end_points
        ALTER COLUMN "nick" SET NOT NULL
    SQL
  end
end
