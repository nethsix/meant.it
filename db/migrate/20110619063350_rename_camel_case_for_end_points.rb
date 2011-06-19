class RenameCamelCaseForEndPoints < ActiveRecord::Migration
  def self.up
    rename_column :end_points, :creatorEndPoint_id, :creator_endpoint_id
    rename_column :end_points, :startTime, :start_time
    rename_column :end_points, :endTime, :end_time
  end

  def self.down
    rename_column :end_points, :creator_endpoint_id, :creatorEndPoint_id
    rename_column :end_points, :start_time, :startTime
    rename_column :end_points, :end_time, :endTime
  end
end
