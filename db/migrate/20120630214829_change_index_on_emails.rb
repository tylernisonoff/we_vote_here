class ChangeIndexOnEmails < ActiveRecord::Migration
  def change
  	remove_index :valid_emails, name: "index_valid_emails_on_email"

  	add_index :valid_emails, [:election_id, :email], unique: true 
  end
end
