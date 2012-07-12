class AddElectionIdToValidEmails < ActiveRecord::Migration
  def change
  	add_column :valid_emails, :election_id, :integer
  	change_column :valid_emails, :election_id, :integer, null: false

  	remove_column :valid_emails, :question_id
  end
end
