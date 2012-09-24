class RemoveDynamicalVoting < ActiveRecord::Migration
  def change
  	remove_column :elections, :dynamic
  end
end
