class RemoveSvc2FromVotes < ActiveRecord::Migration
  def change
  	remove_column :votes, :svc2
  end
end
