class AddFieldsToAppointment < ActiveRecord::Migration
  def self.up
    add_column :appointments, :physician_id, :integer
    add_column :appointments, :patient_id, :integer
  end

  def self.down
    remove_column :appointments, :patient_id
    remove_column :appointments, :physician_id
  end
end
