class RemoveCipherFromVotes < ActiveRecord::Migration
  def change
  	remove_column :votes, :cipher
  end
end
