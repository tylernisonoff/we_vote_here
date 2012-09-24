class RemoveHandleFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :handle

  end
end
