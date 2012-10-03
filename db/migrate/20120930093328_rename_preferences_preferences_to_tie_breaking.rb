class RenamePreferencesPreferencesToTieBreaking < ActiveRecord::Migration
  def change
  	rename_column :preferences, :preferences, :tie_breaking

  end
end
