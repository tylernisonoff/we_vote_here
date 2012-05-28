class FixElections < ActiveRecord::Migration
  def up
  	change_column :elections, :finish_time, :datetime, null: false
  	change_column :elections, :start_time, :datetime, null: false
  	change_column :elections, :name, :string, null: false
  	change_column :elections, :user_id, :integer, null: false

  	remove_column :elections, :privacy
  	remove_column :elections, :display_preference

  	add_column :elections, :private, :boolean, { null: false, default: true }
  	add_column :elections, :display_votes_as_created, :boolean, { null: false, default: false }
  end

  def down
  	change_column :elections, :finish_time, :datetime
  	change_column :elections, :start_time, :datetime
  	change_column :elections, :name, :string
  	change_column :elections, :user_id, :integer

  	remove_column :elections, :private
  	remove_column :elections, :display_votes_as_created

  	add_column :elections, :privacy, :integer
  	add_column :elections, :display_preference, :integer
  end
end
