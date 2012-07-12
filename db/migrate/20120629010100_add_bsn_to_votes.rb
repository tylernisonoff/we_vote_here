class AddBsnToVotes < ActiveRecord::Migration
  def change
  	add_column :votes, :bsn, :string
  	change_column :votes, :bsn, :string, null: false

  	rename_column :votes, :svc1, :svc
  end
end
