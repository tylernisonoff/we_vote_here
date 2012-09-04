class AddNullFalseToActiveVotes < ActiveRecord::Migration
  def change
  	change_column :active_votes, :question_id, :integer, null: false
    change_column :active_votes, :svc, :string, null: false
    change_column :active_votes, :bsn, :string, null: false
  end
end
