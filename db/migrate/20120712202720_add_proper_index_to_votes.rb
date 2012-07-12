class AddProperIndexToVotes < ActiveRecord::Migration
  def change
  	remove_index :votes, :name => "index_votes_on_svc"
  	add_index :votes, :bsn, unique: true
  end
end
