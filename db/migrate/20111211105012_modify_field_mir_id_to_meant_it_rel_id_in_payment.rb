class ModifyFieldMirIdToMeantItRelIdInPayment < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      ALTER TABLE payments
        DROP CONSTRAINT fk_payments_meantItRels;
    SQL
    execute <<-SQL
      ALTER TABLE payments
        RENAME COLUMN mir_id TO meant_it_rel_id;
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ADD CONSTRAINT fk_payments_meantItRels
        FOREIGN KEY ("meant_it_rel_id")
        REFERENCES meant_it_rels(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE payments
        DROP CONSTRAINT fk_payments_meantItRels
    SQL
    execute <<-SQL
      ALTER TABLE payments
        RENAME COLUMN meant_it_rel_id TO mir_id
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ADD CONSTRAINT fk_payments_meantItRels
        FOREIGN KEY ("mir_id")
        REFERENCES meant_it_rels(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
  end
end
