class AddDbLevelStuffForPii < ActiveRecord::Migration
  def self.up
    # Pii : add foreign keys
    execute <<-SQL
      ALTER TABLE piis
        ADD CONSTRAINT fk_piis_endPoints
        FOREIGN KEY ("endPoint_id")
        REFERENCES end_points(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    # Pii : set not null
    execute <<-SQL
      ALTER TABLE piis
        ALTER COLUMN "piiType" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE piis
        ALTER COLUMN "piiValue" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE piis
        ALTER COLUMN "status" SET NOT NULL
    SQL
    # Pii : add unique index
    add_index :piis, [ :piiValue, :piiType], :unique => true, :name => 'by_piiVaue_and_piiType'
  end

  def self.down
  end
end
