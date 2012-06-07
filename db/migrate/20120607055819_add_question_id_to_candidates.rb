class AddQuestionIdToCandidates < ActiveRecord::Migration
  def change
  	add_column :candidates, :candidate_id, :integer
  	change_column :candidates, :candidate_id, :integer, null: false
  	remove_column :candidates, :election_id

  	add_index :candidates, :candidate_id, unique: true
  end
end
