class AddBsnToPreferences < ActiveRecord::Migration
  def change
  	add_column :preferences, :bsn, :string
  	change_column :preferences, :bsn, :string, null: false
  end
end
