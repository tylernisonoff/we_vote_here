class MakeUsersNameNotRequired < ActiveRecord::Migration
  def up
  	change_column :users, :name, :string
  	# this doesn't work... see change_name_to_nickname
  end

  def down
  	change_column :users, :name, :string, null: false
  end
end
