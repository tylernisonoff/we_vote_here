class ChangeElectionIdToNotNull < ActiveRecord::Migration
  def change
  	change_column :voters, :election_id, :integer, null: false
  end
end
