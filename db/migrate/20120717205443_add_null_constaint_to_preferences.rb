class AddNullConstaintToPreferences < ActiveRecord::Migration
  def change
  	change_column :preferences, :svc, :string, null: false
  end
end
