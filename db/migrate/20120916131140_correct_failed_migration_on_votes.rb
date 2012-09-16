class CorrectFailedMigrationOnVotes < ActiveRecord::Migration
  def change

	change_column :votes, :bsn, :integer, null: false
	remove_column :votes, :bsn

  end
end
