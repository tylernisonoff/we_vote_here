class ChangeDisplayVotesToDynamic < ActiveRecord::Migration
  def change
  	rename_column :elections, :display_votes_as_created, :dynamic
  end
end
