class AddSvcToPreferences < ActiveRecord::Migration
  def change
  	remove_column :preferences, :vote_id
  	add_column :preferences, :svc, :string
  	change_column :preferences, :svc, :string, unique: true

  	remove_index :preferences, :name => "index_preferences_on_vote_id_and_choice_id"
  	remove_index :preferences, :name => "index_preferences_on_vote_id_and_position"

  	add_index :preferences, [:svc, :choice_id], unique: true
  	add_index :preferences, [:svc, :position], unique: true
  end
end
