class EliminateActiveTables < ActiveRecord::Migration
  def change
  	drop_table :active_votes
  	drop_table :active_preferences

  	add_column :votes, :active, :boolean, default: false
  	add_column :preferences, :active, :boolean, default: true

  end
end
