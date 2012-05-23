class RemoveUserIdFromElections < ActiveRecord::Migration
  def up
    remove_column :elections, :user_id
      end

  def down
    add_column :elections, :user_id, :integer
  end
end
