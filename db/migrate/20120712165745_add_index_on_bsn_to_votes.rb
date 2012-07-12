class AddIndexOnBsnToVotes < ActiveRecord::Migration
  def change
  	add_index :votes, :bsn, unique: true
  end
end
