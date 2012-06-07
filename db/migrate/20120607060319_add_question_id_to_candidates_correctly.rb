class AddQuestionIdToCandidatesCorrectly < ActiveRecord::Migration
  def change
  	add_column :candidates, :question_id, :integer
  	change_column :candidates, :question_id, :integer, null: false
  	remove_column :candidates, :candidate_id

  	add_index :candidates, :question_id, unique: true
  end
end
