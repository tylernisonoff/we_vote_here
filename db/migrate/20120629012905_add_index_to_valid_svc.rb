class AddIndexToValidSvc < ActiveRecord::Migration
  def change
  	remove_index :valid_svcs, name: "index_valid_svcs_on_svc_and_question_id"
  	remove_index :votes, name: "index_votes_on_question_id_and_svc1"

  	add_index :valid_svcs, :svc, unique: true

  end
end
