class EditVotes < ActiveRecord::Migration
  def up
  	remove_column :votes, :election_id
  	add_column :votes, :question_id, :integer
  	change_column :votes, :question_id, :integer, null: false

  	add_index :votes, [:question_id, :rijndael_or_user_id], unique: true
  end

  def down
  	remove_index :votes, [:question_id, :rijndael_or_user_id]

  	remove_column :votes, :question_id
  	add_column :votes, :election_id, :integer
  end
end
