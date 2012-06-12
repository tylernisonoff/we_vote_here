class FixVotesIdentifier < ActiveRecord::Migration
  def up
  	remove_column :votes, :rijndael_or_user_id
  	add_column :votes, :rijndael, :string
  	change_column :votes, :rijndael, :string, null: false
  	add_index :votes, :rijndael, unique: true
  end

  def down
  	add_column :votes, :rijndael_or_user_id
  	remove_column :votes, :rijndael, :string
  	change_column :votes, :rijndael_or_user_id, :string, null: false
  	add_index :votes, :rijndael_or_user_id, unique: true
  end
end
