class FixVotes < ActiveRecord::Migration
  def up
  	change_column :votes, :user_id, :integer, null: true
	change_column :votes, :election_id, :integer, null: true
  	change_column :votes, :user_id, :integer, null: true

  	add_index :votes, [:election_id, :user_id], unique: true
  end

  def down
  	change_column :votes, :user_id, :integer
	change_column :votes, :election_id, :integer
  	change_column :votes, :user_id, :integer

  	remove_index :votes, [:election_id, :user_id], unique: true
  end
end
