class AddCorrectIndexOnPreferencesWithVotesAndChoices < ActiveRecord::Migration
  def change
  	remove_index :preferences, name: "index_preferences_on_vote_id_and_choice_id"
  	add_index :preferences, [:vote_id, :choice_id], unique: true
  end
end
