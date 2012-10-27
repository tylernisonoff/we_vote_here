class RemoveNullFalseFromElectionGroupId2 < ActiveRecord::Migration
  def change
  	change_column :elections, :group_id, :integer, null: true
  end
end
