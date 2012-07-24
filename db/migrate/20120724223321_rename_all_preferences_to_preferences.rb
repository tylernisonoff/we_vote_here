class RenameAllPreferencesToPreferences < ActiveRecord::Migration
  def change
  	rename_table :all_preferences, :preferences
  end
end
