class RenameElectionsToGroups < ActiveRecord::Migration
  def change
  	rename_table :elections, :groups

  	remove_column :groups, :start_time
  	remove_column :groups, :finish_time

  	add_column :questions, :start_time, :datetime
  	change_column :questions, :start_time, :datetime, null: false
  	
  	add_column :questions, :finish_time, :datetime
  	change_column :questions, :finish_time, :datetime, null: false


  end
end
