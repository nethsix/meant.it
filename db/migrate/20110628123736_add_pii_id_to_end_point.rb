class AddPiiIdToEndPoint < ActiveRecord::Migration
  def self.up
    add_column :end_points, :pii_id, :integer

    # Add foreign keys
    execute <<-SQL
      ALTER TABLE end_points
        ADD CONSTRAINT fk_endPoints_piis
        FOREIGN KEY ("pii_id")
        REFERENCES piis(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
  end

  def self.down
    remove_column :end_points, :pii_id
  end
end
