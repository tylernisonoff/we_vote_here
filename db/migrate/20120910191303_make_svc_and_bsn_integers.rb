class MakeSvcAndBsnIntegers < ActiveRecord::Migration
  def change
	
	# active_preferences
  change_column :active_preferences, :svc, :integer, null: false
	change_column :active_preferences, :bsn, :integer, null: false

  # preferences
  change_column :preferences, :bsn, :integer, null: false 

	# active_votes
  change_column :active_votes, :svc, :integer, null: false
	change_column :active_votes, :bsn, :integer, null: false    

	# valid_svcs
  change_column :valid_svcs, :svc, :integer, null: false
  
  # votes - THIS WAS POOR, I DIDN'T CALL IT VOTES
  change_column :active_votes, :svc, :integer, null: false
	change_column :active_votes, :bsn, :integer, null: false  
  
  end
end
