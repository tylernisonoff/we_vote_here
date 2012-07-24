class AddAttributesToInactivePreferences < ActiveRecord::Migration

  def change
  	add_column :inactive_preferences, :bsn, :string
  	change_column :inactive_preferences, :bsn, :string, null: false

  	add_column :inactive_preferences, :position, :integer
  	change_column :inactive_preferences, :position, :integer, null: false

	add_column :inactive_preferences, :choice_id, :integer
  	change_column :inactive_preferences, :choice_id, :integer, null: false

  	add_index :inactive_preferences, [:bsn, :choice_id], unique: true
  	add_index :inactive_preferences, [:bsn, :position], unique: true

  end
end
