class AddPreferenceIdToActivePreference < ActiveRecord::Migration
  def change
  	add_column :active_preferences, :preference_id, :integer
  	change_column :active_preferences, :preference_id, :integer, null: false

  	add_index :active_preferences, :preference_id, unique: true
  end
end
