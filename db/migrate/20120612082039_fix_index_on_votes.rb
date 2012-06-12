class FixIndexOnVotes < ActiveRecord::Migration
  def change
  	remove_index :votes, [:rijndael]
  	remove_index :votes, [:question_id, :rijndael_or_user_id]
  	add_column :votes, :handle_digest, :string
  	change_column :votes, :handle_digest, :string, null: false
  	add_index :votes, [:question_id, :handle_digest], unique: true
  end
end
