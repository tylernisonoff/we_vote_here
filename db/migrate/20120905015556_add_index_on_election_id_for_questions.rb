class AddIndexOnElectionIdForQuestions < ActiveRecord::Migration
  def change
  	add_index :questions, :election_id
  end
end
