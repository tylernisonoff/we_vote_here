class EditPreferences < ActiveRecord::Migration
  def up
    add_column :preferences, :question_id, :integer
    change_column :preferences, :question_id, :integer, null: false
    remove_column :preferences, :election_id
  end

  def down
  	remove_column :preferences, :question_id
    remove_column :preferences, :election_id, :integer
  end
end
