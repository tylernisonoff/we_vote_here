class AddUserIdToElections < ActiveRecord::Migration
  def change
    add_column :elections, :user_id, :integer
  end
end
