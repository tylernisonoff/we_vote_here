class DeleteElectionInfo < ActiveRecord::Migration
  def change

  	remove_column :elections, :info
  end
end
