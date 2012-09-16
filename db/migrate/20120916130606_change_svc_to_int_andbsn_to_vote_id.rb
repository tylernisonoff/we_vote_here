class ChangeSvcToIntAndbsnToVoteId < ActiveRecord::Migration
  def change

  	# active_preferences
  	change_column :active_preferences, :svc, :string, null: false
  	rename_column :active_preferences, :bsn, :vote_id

  	# preferences - DROPPED THE BALL AND DIDN'T DO THIS, IN OTHER FILE.
  	change_column :preferences, :bsn, :integer, null: false 

	# active_votes
  	change_column :active_votes, :svc, :string, null: false
	rename_column :active_votes, :bsn, :vote_id    

	# valid_svcs
  	change_column :valid_svcs, :svc, :string, null: false
  
  	# votes migration in other file
    add_column :active_votes, :vote_id, :integer
    change_column :active_votes, :vote_id, unique: true



  end
end
