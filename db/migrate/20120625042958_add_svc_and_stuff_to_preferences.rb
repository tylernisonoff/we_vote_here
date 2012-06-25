class AddSvcAndStuffToPreferences < ActiveRecord::Migration
  def change
  	add_column :preferences, :svc1, :string
  	change_column :preferences, :svc1, :string, null: false

  	remove_column :preferences, :vote_id
  	remove_column :preferences, :question_id

  	remove_index :preferences, :name => "index_preferences_on_vote_id_and_candidate_id"
  	remove_index :preferences, :name => "index_preferences_on_vote_id_and_position"

  	add_index "preferences", ["svc1", "candidate_id"], :unique => true
  	add_index "preferences", ["svc1", "position"], :unique => true
  end
end
