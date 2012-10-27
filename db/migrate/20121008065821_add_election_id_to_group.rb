class AddElectionIdToGroup < ActiveRecord::Migration
  def change
  	add_column :groups, :election_id, :integer

  	add_index :groups, [:election_id], unique: true
  end
end
