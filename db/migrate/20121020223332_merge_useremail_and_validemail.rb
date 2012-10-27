class MergeUseremailAndValidemail < ActiveRecord::Migration
  def change
  	remove_column :valid_emails, :group_id
  	remove_column :voters, :group_id
  end
end
