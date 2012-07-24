class AddShowTimestampsToElections < ActiveRecord::Migration
  def change
  	add_column :elections, :record_time, :boolean
  	change_column :elections, :record_time, :boolean, default: true, null: false
  end
end
