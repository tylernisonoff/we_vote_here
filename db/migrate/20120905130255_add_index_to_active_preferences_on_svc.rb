class AddIndexToActivePreferencesOnSvc < ActiveRecord::Migration
  def change
  	add_index :active_preferences, :svc
  	add_index :active_preferences, :bsn
  	
  	add_index :preferences, :bsn

  	end
end
