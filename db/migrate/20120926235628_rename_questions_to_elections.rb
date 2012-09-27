class RenameQuestionsToElections < ActiveRecord::Migration
  def change
  	rename_table :questions, :elections
    remove_index :elections, name: "index_questions_on_group_id"
  	add_index :elections, :group_id

  	rename_column :choices, :question_id, :election_id
  	remove_index :choices, name: "index_choices_on_question_id_and_name"
  	add_index :choices, [:election_id, :name], unique: true

  	rename_column :results, :question_id, :election_id
  	remove_index :results, name: "index_results_on_question_id_and_choice_id"
	add_index :results, [:election_id, :choice_id], unique: true

	rename_column :valid_svcs, :question_id, :election_id

	rename_column :votes, :question_id, :election_id
  end
end
