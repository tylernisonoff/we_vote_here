class AddTieBreakingVoteBoolean < ActiveRecord::Migration
  def change
  	add_column :votes, :tie_breaking, :boolean, default: false 
  	add_column :preferences, :preferences, :boolean, default: false
  end
end
