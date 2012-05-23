class RemoveElectionIdFromElections < ActiveRecord::Migration
  def up
  	remove_column :elections, :election_id
  end

  def down
  	add_column :elections, :election_id, :integer
  end
end
