class AddTrashedMaterial < ActiveRecord::Migration
  def change

  	add_column :choices, :trashed, :boolean, default: false
  	add_column :groups, :trashed, :boolean, default: false
  	add_column :preferences, :trashed, :boolean, default: false
  	add_column :questions, :trashed, :boolean, default: false
  	add_column :results, :trashed, :boolean, default: false
  	add_column :users, :trashed, :boolean, default: false
  	add_column :valid_svcs, :trashed, :boolean, default: false
  	add_column :voters, :trashed, :boolean, default: false
  	add_column :voters, :user_id, :integer
  	add_column :votes, :trashed, :boolean, default: false

  end
end
