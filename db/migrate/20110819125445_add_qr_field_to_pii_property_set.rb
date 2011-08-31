class AddQrFieldToPiiPropertySet < ActiveRecord::Migration
  def self.up
    add_column :pii_property_sets, :qr_file_name, :string
    add_column :pii_property_sets, :qr_content_type, :string
    add_column :pii_property_sets, :qr_file_size, :integer
    add_column :pii_property_sets, :qr_updated_at, :datetime
  end

  def self.down
    remove_column :pii_property_sets, :qr_updated_at
    remove_column :pii_property_sets, :qr_file_size
    remove_column :pii_property_sets, :qr_content_type
    remove_column :pii_property_sets, :qr_file_name
  end
end
