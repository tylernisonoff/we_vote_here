class AddIndexToActiveVotesOnQuestionId < ActiveRecord::Migration
  def change
  	add_index :active_votes, :question_id
  end
end
