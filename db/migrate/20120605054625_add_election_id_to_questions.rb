class AddElectionIdToQuestions < ActiveRecord::Migration
  def change
  	add_column :questions, :election_id, :integer
  	change_column :questions, :election_id, :integer, null: false
  end
end
