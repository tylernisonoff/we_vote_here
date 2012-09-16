class RemoveBsnFromIndexName < ActiveRecord::Migration
  def change

  	remove_index :preferences, name: "index_preferences_on_bsn_and_choice_id"
  	remove_index :preferences, name: "index_preferences_on_bsn"
  
  	add_index :preferences, :vote_id
  	add_index :preferences, [:vote_id, :choice_id], unique: true

  end
end
