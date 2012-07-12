class AddIndexOnSvcToVotes < ActiveRecord::Migration
  def change
  	remove_index :votes, :name => "index_votes_on_bsn"
  	add_index :votes, :svc, unique: true
  end
end
