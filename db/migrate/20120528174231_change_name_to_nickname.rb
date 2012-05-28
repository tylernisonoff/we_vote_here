class ChangeNameToNickname < ActiveRecord::Migration
  def up
  	remove_column :users, :name
  	add_column :users, :nickname, :string
  end

  def down
  	remove_column :users, :nickname
  	add_column :users, :name, :string
  end
end
