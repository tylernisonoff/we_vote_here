class RemoveTrashedFromAll < ActiveRecord::Migration
  def change
  	remove_column :choices, :trashed
  	remove_column :elections, :trashed
  	remove_column :groups, :trashed
  	remove_column :preferences, :trashed
  	remove_column :results, :trashed
  	remove_column :users, :trashed
  	remove_column :valid_emails, :trashed
  	remove_column :voters, :trashed
  	remove_column :votes, :trashed

  end
end
