class ChangeHandleAtPasswordDigestToSvcs < ActiveRecord::Migration
  def change
  	remove_index :votes, name: :index_votes_on_question_id_and_handle_at_password_digest
  	remove_column :votes, :handle_at_password_digest
  	add_column :votes, :svc1, :string
  	change_column :votes, :svc1, :string, null: false
  	add_column :votes, :svc2, :string
  	change_column :votes, :svc2, :string, null: false
  end
end
