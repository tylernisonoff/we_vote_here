class ChangeOccurancesOfElectionInSchema < ActiveRecord::Migration
  def change 

  	rename_column :questions, :election_id, :group_id

  	remove_index :questions, :name => "index_questions_on_election_id"
  	add_index :questions, :group_id


 	rename_column :valid_emails, :election_id, :group_id

 	rename_column :voters, :election_id, :group_id

  end
end
