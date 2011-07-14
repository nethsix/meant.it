class AddLoginPasswordFieldInEntity < ActiveRecord::Migration
  def self.up
    add_column :entities, :login_name, :string
    add_column :entities, :password_hash, :string
    add_column :entities, :password_salt, :string
    # Add unique index
    add_index :entities, [ :login_name ], :unique => true, :name => 'by_login_name'
  end

  def self.down
    remove_column :entities, :login_name
    remove_column :entities, :password_hash
    remove_column :entities, :password_salt
  end
end
