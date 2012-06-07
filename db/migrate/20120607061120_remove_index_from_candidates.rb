class RemoveIndexFromCandidates < ActiveRecord::Migration
  def change
  	remove_index :candidates, :question_id 
  end
end
