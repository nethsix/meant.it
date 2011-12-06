class AddDbLevelStuffForPayment < ActiveRecord::Migration
  def self.up
    # Payments: add a foreign key
    execute <<-SQL
      ALTER TABLE payments
        ADD CONSTRAINT fk_payments_meantItRels
        FOREIGN KEY ("mir_id")
        REFERENCES meant_it_rels(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    SQL
    # These cannot be nil:
    # - item_no
    # - amount
    # - status
    # NOTE: we allow quantity to be nil, to be flexible,
    # e.g., donation
    execute <<-SQL
      ALTER TABLE payments
        ALTER COLUMN "item_no" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ALTER COLUMN "amount" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ALTER COLUMN "status" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ALTER COLUMN "invoice_no" SET NOT NULL
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE payments
        DROP CONSTRAINT fk_payments_meantItRels
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ALTER COLUMN "item_no" DROP NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ALTER COLUMN "amount" DROP NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ALTER COLUMN "status" DROP NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE payments
        ALTER COLUMN "invoice_no" DROP NOT NULL
    SQL
  end
end
