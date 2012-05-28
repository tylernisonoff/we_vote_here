class FixUsers < ActiveRecord::Migration
  def up
  	change_column :users, :email, :string, null: false
  	change_column :users, :name, :string, null: false
  	change_column :users, :password_digest, :string, null: false
  	change_column :users, :handle, :string, null: false
  end

  def down
  	change_column :users, :email, :string
  	change_column :users, :name, :string
  	change_column :users, :password_digest, :string
  	change_column :users, :handle, :string
  end
end
