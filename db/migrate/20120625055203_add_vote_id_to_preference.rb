class AddVoteIdToPreference < ActiveRecord::Migration
  def change
  	add_column :preferences, :vote_id, :integer
  	remove_column :preferences, :svc1, :string

  	remove_index :preferences, name: "index_preferences_on_svc1_and_candidate_id"
  	remove_index :preferences, name: "index_preferences_on_svc1_and_position"

  	add_index "preferences", ["vote_id", "candidate_id"], :unique => true
  	add_index "preferences", ["vote_id", "position"], :unique => true
  end
end
