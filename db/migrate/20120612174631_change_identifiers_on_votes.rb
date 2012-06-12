class ChangeIdentifiersOnVotes < ActiveRecord::Migration
  def change
  	remove_column :votes, :rijndael
  	add_column :votes, :cipher, :string

  	remove_column :votes, :handle_digest
  	add_column :votes, :handle_at_password_digest, :string
  	change_column :votes, :handle_at_password_digest, :string, null: false
  end
end
