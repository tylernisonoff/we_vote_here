class AddIndexOnActiveVotes < ActiveRecord::Migration
  def change
  	add_index :active_votes, :svc, unique: true
  end
end
