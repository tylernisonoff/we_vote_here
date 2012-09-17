class IndexActivePreferencesOnVoteIdAndChoiceId < ActiveRecord::Migration
  def change
  	add_index :active_preferences, [:vote_id, :choice_id], unique: true
  end
end
