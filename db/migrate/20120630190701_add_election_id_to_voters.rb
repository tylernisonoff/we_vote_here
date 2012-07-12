class AddElectionIdToVoters < ActiveRecord::Migration
  def change
  	add_column :voters, :election_id, :integer
  	change_column :voters, :election_id, :integer, unique: true

  	remove_column :voters, :question_id
  end
end
