class CreateInboundEmails < ActiveRecord::Migration
  def self.up
    create_table :inbound_emails do |t|
      t.text :headers
      t.text :body_text
      t.text :body_html
      t.string :from
      t.string :to
      t.string :cc
      t.text :subject
      t.text :dkim
      t.text :spf
      t.text :envelope
      t.text :charsets
      t.string :spam_score
      t.text :spam_report
      t.integer :attachment_count

      t.timestamps
    end
    execute <<-SQL
      ALTER TABLE inbound_emails
        ALTER COLUMN headers SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE inbound_emails
        ALTER COLUMN "from" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE inbound_emails
        ALTER COLUMN "to" SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE inbound_emails
        ALTER COLUMN envelope SET NOT NULL
    SQL
    execute <<-SQL
      ALTER TABLE inbound_emails
        ALTER COLUMN attachment_count SET NOT NULL
    SQL
  end

  def self.down
    drop_table :inbound_emails
  end
end
