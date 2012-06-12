class AddIndicesToCandidatesAndVotes < ActiveRecord::Migration
  def change
  	remove_index :candidates, name: :index_candidates_on_election_id_and_name
	remove_index :votes, name: :index_votes_on_question_id_and_handle_digest

	add_index :candidates, [:question_id, :name], unique: true
	add_index :votes, [:question_id, :handle_at_password_digest], unique: true
  end
end
