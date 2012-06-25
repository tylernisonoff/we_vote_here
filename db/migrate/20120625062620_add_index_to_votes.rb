class AddIndexToVotes < ActiveRecord::Migration
  def change
  	add_index :votes, [:question_id, :svc1], unique: true
  end
end
