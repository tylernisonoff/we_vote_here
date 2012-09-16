class MakePreferencesHaveVoteIdsInsteadOfBsns < ActiveRecord::Migration
  def change

  	# preferences
  	rename_column :preferences, :bsn, :vote_id
  	add_column :preferences, :svc, :string
  	add_index :preferences, :svc

  	# change name of index on active_preferences
  	remove_index :active_preferences, name: "index_active_preferences_on_bsn"
  	add_index :active_preferences, :vote_id

  end
end
