class ChangeCandidatesToChoices < ActiveRecord::Migration
  def change
  	remove_index :choices, name: "index_candidates_on_question_id_and_name"
  	add_index :choices, [:question_id, :name], unique: true

  	add_column :choices, :position, :integer

  	rename_column :preferences, :candidate_id, :choice_id

  	remove_index :preferences, name: "index_preferences_on_vote_id_and_candidate_id"
  	add_index :preferences, [:vote_id, :choice_id]

  	add_index :choices, [:question_id, :position], unique: true

  end
end
