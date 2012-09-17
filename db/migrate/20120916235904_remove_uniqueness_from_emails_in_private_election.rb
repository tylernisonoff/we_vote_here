class RemoveUniquenessFromEmailsInPrivateElection < ActiveRecord::Migration
  def change
  	remove_index "valid_emails", name: "index_valid_emails_on_election_id_and_email"
  end
end
