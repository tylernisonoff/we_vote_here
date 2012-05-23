class AddDisplayPreferenceToElection < ActiveRecord::Migration
  def change
    add_column :elections, :display_preference, :integer
  end
end
