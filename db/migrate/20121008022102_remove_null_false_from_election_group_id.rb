class RemoveNullFalseFromElectionGroupId < ActiveRecord::Migration
  def change
  	change_column :elections, :group_id, :integer
  end
end
