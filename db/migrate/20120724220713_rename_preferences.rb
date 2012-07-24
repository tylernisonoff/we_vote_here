class RenamePreferences < ActiveRecord::Migration
  def change
  	rename_table :preferences, :active_preferences
  	rename_table :inactive_preferences, :all_preferences
  end
end
